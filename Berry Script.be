var lookup_single = {7: 548, 8: 638, 9: 715, 10: 818, 11: 896, 12: 999, 13: 1089, 14: 1166, 15: 1270, 16: 1373}
var lookup_triple = {6: 1553, 7: 1889, 8: 2146, 9: 2391, 10: 2559, 11: 2701, 12: 2830, 13: 3010, 14: 3300}
gpio.pin_mode(25, gpio.DAC)


def heater_power_w(cmd, idx, payload, payload_json)
	print(payload_json)
	var x = int(payload)
	print(x)
	gpio.pin_mode(25, gpio.DAC)
    a = int(x/(230*3))
    if x < 1610:
        tasmota.resp_cmnd_error()
    if a < 6 or a > 16
        tasmota.resp_cmnd_error()
    if x < 4140:
        out_vol = lookup_single[a]
    else:  
        out_vol = lookup_triple[a]
    end
    heater_power(out_vol)
    tasmota.resp_cmnd_str("Set to nearest value of " + a*3*230 + "W")
	print(out_vol)
end
tasmota.add_cmd('HeaterPowerW', heater_power_w)


def heater_power_a(cmd, idx, payload, payload_json)
	print(payload_json)
	var a = int(payload_json['a'])
	var pha = int(payload_json['pha'])
    var out_vol 
    gpio.pin_mode(25, gpio.DAC)
    if a < 6 or a > 16
        tasmota.resp_cmnd_error()
    if pha == 1
        out_vol = lookup_single[a]
    else
        out_vol = lookup_triple[a]
    end

    heater_power(out_vol)
end

tasmota.add_cmd('HeaterPowerA', heater_power_a)

def heater_power(out_vol)
    tasmota.remove_timer(1)
    gpio.dac_voltage(25, out_vol)
    tasmota.set_power(1, true)
    tasmota.set_power(0, true)
    tasmota.delay(10)
    tasmota.set_power(2, true)
end


def fan_off() tasmota.set_power(1, false) end

def heater_power_off()
    gpio.dac_voltage(25, 0)
    tasmota.set_power(0, false)
    tasmota.delay(10)
    tasmota.set_power(2, false)
    tasmota.set_timer(120000, fan_off, 1)
    tasmota.resp_cmnd_str('Heater power off')
end



def heater_wh(cmd, idx, payload, payload_json)
	print(payload)
	gpio.pin_mode(25, gpio.DAC)
    
    if !tasmota.time_reached(0)
        tasmota.resp_cmnd_error()
    end

    var x = int(payload)

	var steps = 9000/3300

    var heatingpower
    if x > 10000
        heatingpower = 9000
    elif x > 5000
        heatingpower = 5000
    else
        heatingpower = 3000 # default
    end

	var out_vol = heatingpower/steps
	
    # Get millisecods for wh calculation
	var timer = int((x / heatingpower) * 3600000) # 3600000ms = 1 hour

	print(out_vol, timer)   # debug
	if x < 100
		tasmota.set_power(0, false)
		tasmota.resp_cmnd_error()
	else
		tasmota.set_power(0, true)
		gpio.dac_voltage(25, out_vol)
        tasmota.set_timer(timer, heater_power_off )
        tasmota.resp_cmnd_str('Set to ' + heatingpower + 'W for ' + timer + 'ms')
	end
end
tasmota.add_cmd('HeaterWh', heater_wh)

# def convert_temp(cmd, idx, payload, payload_json)
#     if payload_json == nil
#         tasmota.resp_cmnd_error()
#     end
#     print(payload_json)
#     import json
#     import math
#     var T0 = 298.15
#     var Rs = real(payload_json['Rs'])
#     var R0 = real(payload_json['R0'])
#     var Beta = real(payload_json['Beta'])
#     print(Rs, R0, Beta)
#     var Vs = 3.3
#     var adcMax = 4095

#     var A = 'A'+ str(payload_json['A'])

#     print (A)
#     var m = (json.load(tasmota.read_sensors()))['ANALOG'][A]
#     print (m)

#     var Vout = m * Vs / adcMax
#     print (Vout)
#     var Rt = Rs * Vout / (Vs - Vout)
#     print (Rt)
#     var T = 1 / (1 / T0 + math.log(Rt / R0) / Beta)
#     print (T)
#     var Tc = T - 273.15
#     print (Tc)
#     tasmota.resp_cmnd_str(Tc)
# end
# tasmota.add_cmd('convtemp', convert_temp)
