var lookup_single = {7: 548, 8: 638, 9: 715, 10: 818, 11: 896, 12: 999, 13: 1089, 14: 1166, 15: 1270, 16: 1373}
var lookup_triple = {6: 1553, 7: 1889, 8: 2146, 9: 2391, 10: 2559, 11: 2701, 12: 2830, 13: 3010, 14: 3300}
gpio.pin_mode(25, gpio.DAC)
var out_vol = 0
var status = {"fwv": "052.1", "car" : 3, "alw" : false, "frc" : 1, "amp" : 16, "err" : 0, "eto" : 0, "psm" : 1, "stp" : 0, "tmp" : 0.0, "tma" : 0.0, "trx" : 0, "nrg" : [], "wh" : 0.0, "cards" : [], "dac_out" : 0}

import string
import json


def heater_power(out_vol)
    if status["err"] == 13
        print "Temp to high"
        return
    end
    tasmota.remove_timer(1)
    gpio.dac_voltage(25, out_vol)
    print(out_vol)
    tasmota.set_power(1, true)
    tasmota.set_power(0, true)
    tasmota.delay(10)
    tasmota.set_power(2, true)
    status["alw"] = true
    status["car"] = 2
end


def contactor_off()
    tasmota.set_power(0, false)
    tasmota.set_power(1, false)
    tasmota.set_power(2, false)
    print("Contactor off")
end

def heater_power_off()
    if (tasmota.get_power() == [false,true,false] || tasmota.get_power() == [false,false,false])
        return
    end
    gpio.dac_voltage(25, 0)
    status["dac_out"] = 0
    tasmota.set_timer(300000, contactor_off, 1)

    # tasmota.set_power(0, false)
    # tasmota.delay(10)
    # tasmota.set_power(2, false)
    if status["car"] != 1
        status["car"] = 4
    end
    status["alw"] = false
    tasmota.resp_cmnd_str('Heater power off')
end

heater_power_off()
contactor_off()


def safety_power_off()
    if tasmota.cmd('status 10')['StatusSNS']['DS18B20']['Temperature'] >= 66
        print ('Temperature too high')
        heater_power_off()
        status["err"] = 13
        status["alw"] = false
        status["car"] = 1
    end
    if tasmota.cmd('status 10')['StatusSNS']['DS18B20']['Temperature'] <= 60
        print ('Temperature low enough')
        status["err"] = 0
        if status["car"] == 1
            status["car"] = 3
        end
        # status["alw"] = true
    end
end

tasmota.add_cron('*/20 * * * * *', safety_power_off, 0)


# def heater_power_w(cmd, idx, payload, payload_json)
# 	print(payload_json)
# 	var x = int(payload)
# 	print(x)
# 	gpio.pin_mode(25, gpio.DAC)
#     amp = int(x/(230*3))
#     if x < 1610
#         tasmota.resp_cmnd_error()
#     end
#     if amp < 6 || amp > 16
#         tasmota.resp_cmnd_error()
#     end
#     if x < 4140
#         out_vol = lookup_single[amp]
#     else
#         if amp > 14
#             amp = 14
#         end
#         out_vol = lookup_triple[amp]
#     end
#     heater_power(out_vol)
#     tasmota.resp_cmnd_str("Set to nearest value of " + amp*3*230 + "W")
# 	print(out_vol)
# end
# tasmota.add_cmd('HeaterPowerW', heater_power_w)

def heater_power_a(payload_json)
	print(payload_json)
	var amp = status["amp"]
	var pha = status["psm"]
    gpio.pin_mode(25, gpio.DAC)
    if amp < 6 || amp > 16
        tasmota.resp_cmnd_error()
    end
    if pha == 1
        if amp == 6
            amp = 7
        end
        status["dac_out"] = lookup_single[amp]
    else
        if amp > 14
            amp = 14
        end
        status["dac_out"] = lookup_triple[amp]
    end
    heater_power(status["dac_out"])
end


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
        if status["psm"] == 1
            status["wh"] = status["wh"] + ((230.0*real(lookup_single[status["amp"]]))/3600000.0)
        else
            status["wh"] = status["wh"] + ((230.0*real(lookup_triple[status["amp"]]))/3600000.0)
        end
    end
    status['eto'] = int(status["wh"])
    # status['wh'] = real(energy.total*1000)
end

def goeStatus_temp()
    # status = {"fwv", "car", "alw", "amp", "err", "eto", "psm", "stp", "tmp", "trx", "nrg", "wh", "cards"}
    # status["fwv"] = tasmota.cmd("status 2")["StatusFWR"]["Version"]
    # if tasmota.get_power() == [true,true,true]
    #     print("heater on")
    #     status["car"] = 2
    # elif tasmota.get_power() == [true,true,true] && tasmota.cmd("status 10")["StatusSNS"]["DS18B20"]["Temperature"] >= 64
    #     status["car"] = 4
    # else
    #     status["car"] = 1
    # end
    # if status["car"] == 4
    #     status["alw"] = true
    # else
    #     status["alw"] = false
    # end
    # status["amp"] = amp
    # if tasmota.get_power() == [true,true,true] && tasmota.cmd("status 10")["StatusSNS"]["DS18B20"]["Temperature"] >= 64 
    #     status["err"] = 13
    # else
    #     status["err"] = 0
    # end
    # status["eto"] = energy.total * 1000
    # if out_vol > 1500
    #     status ["psm"] = 2
    # else
    #     status ["psm"] = 1
    # end
    # status["stp"] = 0
    status["tmp"] = tasmota.cmd("status 10")["StatusSNS"]["DS18B20"]["Temperature"]
    # status["tmp"] = json.load(tasmota.read_sensors())["DS18B20"]["Temperature"]
    status["tma"] = status["tmp"]
    status["trx"] = 0
    if (status["frc"] == 1 || status["err"] == 13) && (tasmota.get_power() == [false,true,false] || tasmota.get_power() == [false,false,false] || status["car"] == 4)
        status["nrg"] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 99, 99, 99, 99]
    else
        if status["psm"] == 2
            status["nrg"] = [230, 230, 230, 0, status["amp"]*10, status["amp"]*10, status["amp"]*10, status["amp"]*230/100, status["amp"]*230/100, status["amp"]*230/100, 0, (status["amp"]*230*3), 99, 99, 99, 99]
        else
            status["nrg"] = [230, 0, 0, 0, status["amp"]*10, 0 , 0, status["amp"]*230/100, 0, 0, 0, (status["amp"]*230), 99, 99, 99, 99]
        end
    end
    # status["wh"] = real(energy.total*1000)
    # status["cards"] = []
    print(status)
    return status
    tasmota.resp_cmnd(status)
end
tasmota.add_cmd('goeStatus', goeStatus_temp)

def goeSet(cmd, idx, payload, payload_json)
    # print (payload, payload_json)
    var data = {}
    if string.find(payload,"?") == 0
        var i = string.split(payload, "?")[1]
        data[string.split(i, "=")[0]] = int(string.split(i, "=")[1])
        # print (data)
    else    
        tasmota.resp_cmnd_error()
    end
    

    # data_needed = {"amp", "frc", "psm"}
    if data.contains("amp")
        status["amp"] = data["amp"]
    end
    if data.contains("frc")
        status["frc"] = data["frc"]
        if status["frc"] == 1
            heater_power_off()
            status["alw"] = false
            tasmota.remove_cron(1)
        end
    end
    if data.contains("psm")
        status["psm"] = data["psm"]
    end
    if (status["amp"] < 7 && status["psm"] == 1)
        status["amp"] = 7
    elif (status["amp"] >14 && status["psm"] == 2)
        status["amp"] = 14
    end
    if status["psm"] != 2 && status["frc"] != 1 && status["err"] != 13
        heater_power_a({"amp": status["amp"], "psm": 1})
        tasmota.add_cron("* * * * * *", count_energy, 1)
    elif status["psm"] == 2 && status["frc"] != 1 && status["err"] != 13
        heater_power_a({"amp": status["amp"], "psm": 2})
        tasmota.add_cron("* * * * * *", count_energy, 1)
    else
        heater_power_off()
    end
    tasmota.resp_cmnd(goeStatus_temp)
end
tasmota.add_cmd('goeWrite', goeSet)

# def filter_goe_status(cmd, idx, payload)
#     print (payload)
#     var status = goeStatus_temp()
#     if string.find(payload,"?filter=") == 0
#         print ("filter")
#         var filtered_data = {}
#         var filter = string.split((string.split(payload, "?filter=")[1]), ",")
#         for i : filter
#             print (i)
#             filtered_data.insert(i, status[i])
#         end
#         print (filtered_data)
#         tasmota.resp_cmnd(filtered_data)

#     end    
# end
# tasmota.add_cmd('goeStatusfilter', filter_goe_status)