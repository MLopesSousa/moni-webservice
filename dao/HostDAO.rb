require 'digest'

require File.join(File.expand_path(File.dirname(__FILE__)), 'DataFactory')
require File.join(File.expand_path(File.dirname(__FILE__)), '../entity/Host')
require File.join(File.expand_path(File.dirname(__FILE__)), '../helpers/Cache')
require File.join(File.expand_path(File.dirname(__FILE__)), '../helpers/Socket')

class HostDAO
	def initialize
		@key = 'data:normalizada:host'
		@ret = Cache.new().cache_data?(@key, self)
	end

	def map
		ret = {}
		data = JSON.parse(Cache.new().cache?('data:server','@fields.tipo:"INSTANCE"'))
                data2 = JSON.parse(Cache.new().cache?('data:jvmmemory','@fields.tipo:"JVMMEMORIA"'))
                data3 = JSON.parse(Cache.new().cache?('data:datasource','@fields.tipo:"DATASOURCE"'))
                data4 = JSON.parse(Cache.new().cache?('data:application','@fields.tipo:"APPLICATION"'))
		objects = {}

		data.each do |d|
			begin
                        	desc = d["_source"]["@fields"]["host"][0]
                        	env = d["_source"]["@fields"]["ambiente"][0]
                        	as = d["_source"]["@fields"]["servidor"][0]
                        	server = d["_source"]["@fields"]["instance"][0]
                        	target = { :desc => d["_source"]["@fields"]["target"][0], :as => d["_source"]["@fields"]["servidor"][0] }
				key = "HOST:#{desc}:#{env}"
                        	id = Digest::SHA256.hexdigest(key)

                        	objects[key] ||= {}
				objects[key][:id] = id
				objects[key][:as] ||= []
				objects[key][:as] << as

				objects[key][:server] ||= []
				objects[key][:server] << server

				objects[key][:target] ||= []
				objects[key][:target] << target
			rescue
				
			end
                end

		objects.each do |obj|

	                host = obj[0].split(':')[1]
                        env = obj[0].split(':')[2]
			id = obj[1][:id]
			as = obj[1][:as].uniq
			server = obj[1][:server].uniq
			target = obj[1][:target].uniq

			jvm = [] 
			datasource = [] 
			data = [] 
			application = [] 
			jvmmemory = {}

			begin
				jvm = data2.select do |d|
                                	d["_source"]["@fields"]["ambiente"][0] == env && d["_source"]["@fields"]["host"][0] == host
                        	end
			rescue
			end

			begin
                                app = data4.select do |d|
                                        d["_source"]["@fields"]["ambiente"][0] == env && d["_source"]["@fields"]["host"][0] == host
                                end
			rescue
                        end

			begin
                        	datasource = data3.select do |d|
                                	d["_source"]["@fields"]["ambiente"][0] == env && d["_source"]["@fields"]["host"][0] == host
                        	end
			rescue
			end

			begin
				jvm.each do |d|
                        		jvmmemory[d["_source"]["@fields"]["instance"][0]] = { :max_heap => d["_source"]["@fields"]["MaxHeap"][0], :max_perm_gen => d["_source"]["@fields"]["permGen"][0] }
				end
			rescue
			end
			
			begin
				datasource.each do |d|
					data << { :server => d["_source"]["@fields"]["instance"][0], :desc => d["_source"]["@fields"]["pool"][0], :max_pool => d["_source"]["@fields"]["MaxPoolSize"][0] }
				end
			rescue
			end

			begin
				app.each do |d|
					application << { :desc => d["_source"]["@fields"]["app"][0], :server =>  d["_source"]["@fields"]["instance"][0] }
				end
			rescue
			end

                        ob = Host.new(id, host, env, target, server, application.uniq, data.uniq, as.uniq, jvmmemory)
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
