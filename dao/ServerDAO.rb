require 'digest'

require File.join(File.expand_path(File.dirname(__FILE__)), 'DataFactory')
require File.join(File.expand_path(File.dirname(__FILE__)), '../entity/Server')
require File.join(File.expand_path(File.dirname(__FILE__)), '../helpers/Cache')
require File.join(File.expand_path(File.dirname(__FILE__)), '../helpers/Socket')

class ServerDAO
	def initialize
		@key = 'data:normalizada:server'
		@ret = Cache.new().cache_data?(@key, self)
	end

	def map
		ret = {}
		data = JSON.parse(Cache.new().cache?('data:server','@fields.tipo:"INSTANCE"'))
                data2 = JSON.parse(Cache.new().cache?('data:jvmmemory','@fields.tipo:"JVMMEMORIA"'))
                data3 = JSON.parse(Cache.new().cache?('data:datasource','@fields.tipo:"DATASOURCE"'))
		objects = {}

		data.each do |d|
			begin
                        	desc = d["_source"]["@fields"]["instance"][0]
                        	env = d["_source"]["@fields"]["ambiente"][0]
                        	as = d["_source"]["@fields"]["servidor"][0]
                        	host = d["_source"]["@fields"]["host"][0]
                        	port = d["_source"]["@fields"]["port"][0]
                        	target = d["_source"]["@fields"]["target"][0]
				key = "SERVER:#{desc}:#{env}:#{as}:#{host}"
                        	id = Digest::SHA256.hexdigest(key)

                        	objects[key] ||= {}
				objects[key][:id] = id
                        	objects[key][:port] = port
				objects[key][:target] = target
			end
                end

		objects.each do |obj|

                        server = obj[0].split(':')[1]
                        env = obj[0].split(':')[2]
                        as  = obj[0].split(':')[3]
                        host = obj[0].split(':')[4]
                        port = obj[1][:port]
			id = obj[1][:id]
			target = obj[1][:target]

			jvm = []
			datasource = []
			jvmmemory = {}
			data = []

			begin
				jvm = data2.select do |d|
                                	d["_source"]["@fields"]["instance"][0] == server && d["_source"]["@fields"]["ambiente"][0] == env && d["_source"]["@fields"]["servidor"][0] == as && d["_source"]["@fields"]["host"][0] == host
                        	end
			end

			begin
                        	datasource = data3.select do |d|
                                	d["_source"]["@fields"]["instance"][0] == server && d["_source"]["@fields"]["ambiente"][0] == env && d["_source"]["@fields"]["servidor"][0] == as && d["_source"]["@fields"]["host"][0] == host
                        	end
			end

			begin
                        	if jvm.length > 0 ?
                                	jvmmemory =  {
                                                :max_heap => jvm[0]["_source"]["@fields"]["MaxHeap"][0],
                                                :max_perm_gen => jvm[0]["_source"]["@fields"]["permGen"][0]
                                        }
                                	: jvmmemory = {}
                        	end
			end
			
			#begin
                        #	if datasource.length > 0 ?
                        #        	data =  {
                        #                	        :max_pool => datasource[0]["_source"]["@fields"]["MaxPoolSize"][0],
                        #                	}
                        #        	: data = {}
                        #	end
			#end

			begin
				datasource.uniq!
				datasource.each do |d|
					data << { :desc => d["_source"]["@fields"]["pool"][0], :max_pool => d["_source"]["@fields"]["MaxPoolSize"][0] }
				end
			end

                        ob = Server.new(id, server, env, target, host, as, port, jvmmemory, data)
                        ret[id] = ob.to_s

                end

		return ret
        end

	def list
                return @ret.map { |k,v| v }
        end

	def select(key)
                return [] << @ret[key]
        end

	def status(desc, port)
		_port = port.to_i + 8080
		_status = Socket.is_port_open?(desc, _port)
        	return [] << { :status => _status }
	end

	def purge(id)
		Cache.new().purge_from_historical_data(@key, id)
		return [] << true
	end

end
