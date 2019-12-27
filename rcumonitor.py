# pyinstaller --onefile --icon=img/rcumonitor.ico --noconsole rcumonitor.py
import serial
from DBcm import UseDatabase
import datetime
from secret import host, user, password

debug = 0
TIMEOUT = 5 # wait for 5 sec

def data(rx):
    rx = rx.split(b'=')
    if len(rx) > 1:
        if rx[0] == b'TEMP':
            if len(rx[1]) > 1:
                result = (rx[1][0] + rx[1][1])/2
        else:
            result = rx
    elif rx == b'':
        result = 'No data'
    else:
        result = rx
    if debug: print(result)
    return result

def temp(com):
    with serial.Serial(com, 19200, timeout=TIMEOUT) as ser:
        if debug: print('Connected to {}'.format(com))
        ser.write(b'TC?  ') # 5 bytes
        rx = ser.read(100)
        if rx.startswith(b'REMOTE\r\n') or rx.startswith(b'END\r\n') or rx == b'':
            ser.write(b'TC?  ')
            rx = ser.read(100)
        if debug: print(rx)
        t = data(rx)
        print('Temperature {} {} C'.format(com, t))
    if debug: print('Disconnected from {}'.format(com))
    return t

def insert(com, address, param, value):
    with UseDatabase(dbconfig) as cursor:
        _SQL = """SELECT value
                  FROM data
                  WHERE network_id = (
                      SELECT network_id FROM network
                      WHERE ne_id =
                      (SELECT ne_id FROM ne WHERE com = %s)
                      AND address = %s
                  )
                  AND param_id = (
                      SELECT param_id FROM param
                      WHERE name = %s
                      AND equipment_id = (
                          SELECT equipment_id FROM network
                          WHERE ne_id = (SELECT ne_id FROM ne WHERE com = %s)
                          AND address = %s)
                  )
                  ORDER BY date DESC
                  LIMIT 1;"""
        cursor.execute(_SQL, (com, address, param, com, address))
        last_value = cursor.fetchone()
        # Если нет значения или оно не равно предыдущему, то вставка в БД.
        if not last_value or value != last_value[0]:
            _SQL = """INSERT INTO data
                      (date, network_id, param_id, value)
                      VALUES (
                      %s,
                      (SELECT network_id FROM network
                      WHERE ne_id =
                      (SELECT ne_id FROM ne WHERE com = %s)
                      AND address = %s),
                      (SELECT param_id FROM param
                      WHERE name = %s
                      AND equipment_id = (
                          SELECT equipment_id FROM network
                          WHERE ne_id = (SELECT ne_id FROM ne WHERE com = %s)
                          AND address = %s)),
                      %s
                      );"""
            cursor.execute(_SQL, (datetime.datetime.now(),
                                  com,
                                  address,
                                  param,
                                  com,
                                  address,
                                  value)
                           )

def limits(com, address, param, value):
    with UseDatabase(dbconfig) as cursor:
        _SQL = """SELECT low, prelow, prehigh, high
                  FROM param
                  WHERE equipment_id = (
                      SELECT equipment_id FROM network
                      WHERE ne_id = (SELECT ne_id FROM ne WHERE com = %s)
                      AND address = %s)
                  AND name = %s;"""
        cursor.execute(_SQL, (com, address, param))
        limits = cursor.fetchone()
        if value < limits[0]:
            status = 'Низкое значение {} < {}'.format(value, limits[0])
            severity = 1
        elif value > limits[3]:
            status = 'Высокое значение {} > {}'.format(value, limits[3])
            severity = 1
        elif value < limits[1]:
            status = 'Низкое значение {} < {}'.format(value, limits[1])
            severity = 4
        elif value > limits[2]:
            status = 'Высокое значение {} > {}'.format(value, limits[2])
            severity = 4
        else:
            status = 'Норма'
            severity = 5
        return (severity, status)

def alarm_log(com, address, param, event):
    severity = event[0]
    status = event[1]
    timestamp = datetime.datetime.now()
    with UseDatabase(dbconfig) as cursor:
        _SQL = """SELECT *
                  FROM log
                  WHERE network_id = (
                      SELECT network_id FROM network
                      WHERE ne_id = (SELECT ne_id FROM ne WHERE com = %s)
                      AND address = %s)
                  AND param_id = (
                      SELECT param_id FROM param WHERE name = %s
                      AND equipment_id = (
                          SELECT equipment_id FROM network
                          WHERE ne_id = (SELECT ne_id FROM ne WHERE com = %s)
                          AND address = %s))
                  AND cleared = 0
                  ORDER BY log_id DESC
                  LIMIT 1;"""
        cursor.execute(_SQL, (com, address, param, com, address))
        last_event = cursor.fetchone()
        if not last_event and severity < 5:
            _SQL = """INSERT INTO log (
                                       event_time,
                                       clear_time,
                                       network_id,
                                       param_id,
                                       severity_id,
                                       event,
                                       cleared,
                                       ack
                                       ) VALUES (
                        %s, %s,
                        (SELECT network_id FROM network
                        WHERE ne_id =
                        (SELECT ne_id FROM ne WHERE com = %s)
                        AND address = %s),
                        (SELECT param_id FROM param WHERE name = %s
                            AND equipment_id =
                            (SELECT equipment_id FROM network
                            WHERE ne_id = (SELECT ne_id FROM ne WHERE com = %s)
                            AND address = %s)),
                        %s, %s, 0, 0);"""
            cursor.execute(_SQL, (timestamp, timestamp, com, address, param,
                                  com, address, severity, status))
            _SQL = """UPDATE last_update SET update_time = %s
                      WHERE last_update_id = 1;"""
            cursor.execute(_SQL, (datetime.datetime.now(),))
        elif last_event and severity == 5:
            _SQL = """UPDATE log SET
                      event_time = event_time,
                      clear_time = %s,
                      cleared = 1
                      WHERE log_id = %s;"""
            cursor.execute(_SQL, (timestamp, last_event[0]))
            _SQL = """UPDATE last_update SET update_time = %s
                      WHERE last_update_id = 1;"""
            cursor.execute(_SQL, (datetime.datetime.now(),))

def data_request(com, addresses):
    with serial.Serial(com, 19200, timeout=TIMEOUT) as ser:
        if debug: print('Connected to {}'.format(com))
        for address in addresses:
            print('Request address {}'.format(address))
            ser.write(b'CR' + bytes([address]) + b'\x03\x88')
            rx = ser.read(100)
            if debug: print(rx)
            if rx.startswith(b'A\xff'):
                param_values(rx, com, address)
    if debug: print('Disconnected from {}'.format(com))

def insert_many(com, address, params):
    for param in params:
        insert(com, address, param[0][0], param[1])
        event = limits(com, address, param[0][0], param[1])
        alarm_log(com, address, param[0][0], event)

def dec(a, b=False):
    if not b:
        return int.from_bytes(bytes([a]), "big")
    else:
        return int.from_bytes(bytes([a]) + bytes([b]), "big")

def param_values(b, com, address):
    with UseDatabase(dbconfig) as cursor:
        _SQL = """SELECT name, multiplicator
                  FROM param
                  WHERE equipment_id = (
                  SELECT equipment_id FROM network
                  WHERE ne_id = (SELECT ne_id FROM ne WHERE com = %s)
                  AND address = %s
                  ) ORDER BY param_id;"""
        cursor.execute(_SQL, (com, address))
        params = cursor.fetchall()
    # print(params)
    i = 2
    var = []
    for param in params:
        # print(b, i)
        if param[1] == 'AF2L1':
            v = dec(b[i]) * 1 + dec(b[i + 1]) * 0.1
            i += 2
        elif param[1] == 'AOL0':
            v = dec(b[i]) * 1
            i += 1
        elif param[1] == 'AOL1':
            v = dec(b[i]) * 0.1
            i += 1
        elif param[1] == 'AVL0':
            v = dec(b[i], b[i + 1]) * 1
            i += 2
        elif param[1] == 'AVL1':
            v = dec(b[i], b[i + 1]) * 0.1
            i += 2
        elif param[1] == 'AVL2':
            v = dec(b[i], b[i + 1]) * 0.01
            i += 2
        elif param[1] == 'AVL3':
            v = dec(b[i], b[i + 1]) * 0.001
            i += 2
        elif param[1] == 'AVR0':
            v = dec(b[i], b[i + 1]) * 1
            i += 2
        elif param[1] == 'AVR1':
            v = dec(b[i], b[i + 1]) * 10
            i += 2
        elif param[1] == 'C':
            v = dec(b[i])
            i += 1
        else:
            v.append(9999)
        var.append(round(v, 5))
    # print(var)
    insert_many(com, address, zip(params, var))


if __name__ == '__main__':
    dbconfig = { 'host': host,
                 'user': user,
                 'password': password,
                 'database': "rcu", }
    active = True
    while active:
        with UseDatabase(dbconfig) as cursor:
            _SQL = """SELECT ne_id, com FROM ne WHERE auto = 1;"""
            cursor.execute(_SQL)
            com = cursor.fetchall() # list of tupple with one element
            _SQL = """SELECT ne_id, address FROM network
                      WHERE ne_id IN (SELECT ne_id FROM ne WHERE auto = 1)
                      AND address > 0;"""
            cursor.execute(_SQL)
            tmp = cursor.fetchall()
            network = {}
            for (ne_id, address) in tmp:
                network.setdefault(ne_id, [])
                network[ne_id].append(address)
        for (ne_id, port) in com:
            value = temp(port)
            if type(value) == float:
                insert(port, 0, "T", value)
                event = limits(port, 0, "T", value)
                alarm_log(port, 0, "T", event)
            data_request(port, network[ne_id])
        with UseDatabase(dbconfig) as cursor:
            _SQL = """SELECT auto FROM main WHERE main_id = 1;"""
            cursor.execute(_SQL)
            auto = cursor.fetchone()
            if auto[0] == 0:
                active = False
