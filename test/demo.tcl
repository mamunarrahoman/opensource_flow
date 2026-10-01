foreach port [get_ports *] {
	puts "[get_name $port] : [get_property $port to_pin -object_type port]"
}
