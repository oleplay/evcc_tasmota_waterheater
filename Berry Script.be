var lookup_single = {7: 548, 8: 638, 9: 715, 10: 818, 11: 896, 12: 999, 13: 1089, 14: 1166, 15: 1270, 16: 1373}
var lookup_triple = {6: 1553, 7: 1889, 8: 2146, 9: 2391, 10: 2559, 11: 2701, 12: 2830, 13: 3010, 14: 3300}
gpio.pin_mode(25, gpio.DAC)
var out_vol
var amp
var pha
var set_amp
var set_frc
var set_psm


def heater_power_w(cmd, idx, payload, payload_json)
	print(payload_json)
	var x = int(payload)
	print(x)
	gpio.pin_mode(25, gpio.DAC)
    amp = int(x/(230*3))
    if x < 1610
        tasmota.resp_cmnd_error()
    end
    if amp < 6 || amp > 16
        tasmota.resp_cmnd_error()
    end
    if x < 4140
        out_vol = lookup_single[amp]
    else
        if amp > 14
            amp = 14
        end
        out_vol = lookup_triple[amp]
    end
    heater_power(out_vol)
    tasmota.resp_cmnd_str("Set to nearest value of " + amp*3*230 + "W")
	print(out_vol)
end
tasmota.add_cmd('HeaterPowerW', heater_power_w)


def heater_power_a(payload_json)
	print(payload_json)
	amp = int(payload_json['amp'])
	pha = int(payload_json['psm']) 
    gpio.pin_mode(25, gpio.DAC)
    if amp < 6 || amp > 16
        tasmota.resp_cmnd_error()
    end
    if pha == 1
        if amp == 6
            amp = 7
        end
        out_vol = lookup_single[amp]
    else
        if amp > 14
            amp = 14
        end
        out_vol = lookup_triple[amp]
    end

    heater_power(out_vol)
end

def heater_power(out_vol)
    tasmota.remove_timer(1)
    gpio.dac_voltage(25, out_vol)
    print(out_vol)
    tasmota.set_power(1, true)
    tasmota.set_power(0, true)
    tasmota.delay(10)
    tasmota.set_power(2, true)
end


def fan_off()
    tasmota.set_power(1, false) 
end

def heater_power_off()
    gpio.dac_voltage(25, 0)
    tasmota.set_power(0, false)
    tasmota.delay(10)
    tasmota.set_power(2, false)
    tasmota.set_timer(120000, fan_off, 1)
    tasmota.resp_cmnd_str('Heater power off')
end

def safety_power_off()
    if tasmota.cmd('status 10')['StatusSNS']['DS18B20']['Temperature'] >= 66
        print ('Temperature too high')
        heater_power_off()
    end
end

# Run cron every 20 seconds
tasmota.add_cron('*/20 * * * * *', safety_power_off, 0)

# def heater_wh(cmd, idx, payload, payload_json)
# 	print(payload)
# 	gpio.pin_mode(25, gpio.DAC)
    
#     if !tasmota.time_reached(0)
#         tasmota.resp_cmnd_error()
#     end

#     var x = int(payload)

# 	var steps = 9000/3300

#     var heatingpower
#     if x > 10000
#         heatingpower = 9000
#     elif x > 5000
#         heatingpower = 5000
#     else
#         heatingpower = 3000 # default
#     end

# 	var out_vol = heatingpower/steps
	
#     # Get millisecods for wh calculation
# 	var timer = int((x / heatingpower) * 3600000) # 3600000ms = 1 hour

# 	print(out_vol, timer)   # debug
# 	if x < 100
# 		tasmota.set_power(0, false)
# 		tasmota.resp_cmnd_error()
# 	else
# 		tasmota.set_power(0, true)
# 		gpio.dac_voltage(25, out_vol)
#         tasmota.set_timer(timer, heater_power_off )
#         tasmota.resp_cmnd_str('Set to ' + heatingpower + 'W for ' + timer + 'ms')
# 	end
# end
# tasmota.add_cmd('HeaterWh', heater_wh)

# def status(cmd, idx, payload, payload_json)
#     status = {'fwv', 'car', 'alw', 'amp', 'err', 'eto', 'psm', 'stp', 'tmp', 'trx', 'nrg', 'wh', 'cards'}
#     status['fwv'] = tasmota.cmd("status 2")['StatusFWR']['Version']
#     if tasmota.get_power() == [true,true,true]
#         print('heater on')
#         status['car'] = '2'
#     elif tasmota.get_power() == [true,true,true] && energy.active_power < 500 
#         status['car'] = '4'
#     else
#         status['car'] = '1'
#     end
#     if status['car'] == '4'
#         status['alw'] = true
#     else
#         status['alw'] = false
#     end
#     status['amp'] = amp
#     if tasmota.get_power() == [true,true,true] && energy.active_power < 500 
#         status['err'] = '13'
#     else
#         status['err'] = '0'
#     end
#     status['eto'] = energy.total * 1000
#     if out_vol > 1500
#         status ['psm'] = '2'
#     else
#         status ['psm'] = '1'
#     end
#     status['stp'] = 0
#     status['tmp'] = tasmota.cmd('status 10')['StatusSNS']['DS18B20']['Temperature']
#     status['tma'] = status['tmp']
#     status['trx'] = 0
#     if status['psm'] == 2
#         status['nrg'] = [230, 230, 230, 0, energy.current*10, energy.current_2*10, energy.current_3*10, energy.active_power/100, energy.active_power_2/100, energy.active_power_3/100, 0, (energy.active_power+energy.active_power_2+energy.active_power_3)/10, 99, 99, 99, 99]
#     else
#         status['nrg'] = [230, 0, 0, 0, energy.current*10+energy.current_2*10+energy.current_3*10, 0 , 0, energy.active_power/100+energy.active_power_2/100+energy.active_power_3/100, 0, 0, 0, (energy.active_power+energy.active_power_2+energy.active_power_3)/10, 99, 99, 99, 99]
#     end
#     status['wh'] = real(energy.total*1000)
#     status['cards'] = []

#     tasmota.resp_cmnd(status)

# end


def count_energy()
    if tasmota.get_power() == [true,true,true]
        if pha == 1
            energy.total = energy.total + real(((230*lookup_single[amp])/3600000))
        else
            energy.total = energy.total + ((230*3*lookup_triple[amp]))/3600000
        end
    end
end

def status_temp()
    # status = {'fwv', 'car', 'alw', 'amp', 'err', 'eto', 'psm', 'stp', 'tmp', 'trx', 'nrg', 'wh', 'cards'}
    var status = {}
    status['fwv'] = tasmota.cmd("status 2")['StatusFWR']['Version']
    if tasmota.get_power() == [true,true,true]
        print('heater on')
        status['car'] = '2'
    elif tasmota.get_power() == [true,true,true] && tasmota.cmd('status 10')['StatusSNS']['DS18B20']['Temperature'] >= 64
        status['car'] = '4'
    else
        status['car'] = '1'
    end
    if status['car'] == '4'
        status['alw'] = true
    else
        status['alw'] = false
    end
    status['amp'] = amp
    if tasmota.get_power() == [true,true,true] && tasmota.cmd('status 10')['StatusSNS']['DS18B20']['Temperature'] >= 64 
        status['err'] = '13'
    else
        status['err'] = '0'
    end
    status['eto'] = energy.total * 1000
    if out_vol > 1500
        status ['psm'] = '2'
    else
        status ['psm'] = '1'
    end
    status['stp'] = 0
    status['tmp'] = tasmota.cmd('status 10')['StatusSNS']['DS18B20']['Temperature']
    status['tma'] = status['tmp']
    status['trx'] = 0
    if status['psm'] == 2
        status['nrg'] = [230, 230, 230, 0, status['amp']*10, status['amp']*10, status['amp']*10, status['amp']*230/100, status['amp']*230/100, status['amp']*230/100, 0, (status['amp']*230*3)/10, 99, 99, 99, 99]
    else
        status['nrg'] = [230, 0, 0, 0, status['amp']*10, 0 , 0, status['amp']*230/100, 0, 0, 0, (status['amp']*230)/10, 99, 99, 99, 99]
    end
    status['wh'] = real(energy.total*1000)
    status['cards'] = []
    print(status)
    tasmota.resp_cmnd(status)
end
tasmota.add_cmd('go-eStatus', status_temp)

def set(payload_json)
    var data = payload_json
    # data_needed = {'amp', 'frc', 'psm'}
    if data.contains('amp')
        set_amp = data['amp']
    end
    if data.contains('frc')
        set_frc = data['frc']
        if set_frc == 1
            heater_power_off()
            tasmota.remove_cron(1)
        end
    end
    if data.contains('psm')
        set_psm = data['psm']
    end
    if (set_amp < 7 && set_psm == 1)
        set_amp = 7
    elif (set_amp >14 && set_psm == 2)
        set_amp = 14
    end
    if set_psm != 2 && set_frc != 1
        heater_power_a({'amp': set_amp, 'psm': 1})
        tasmota.add_cron('* * * * * *', count_energy, 1)
    elif set_psm == 2 && set_frc != 1
        heater_power_a({'amp': set_amp, 'psm': 2})
        tasmota.add_cron('* * * * * *', count_energy, 1)
    else
        heater_power_off()
    end     
end