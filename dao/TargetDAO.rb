require 'digest'
require File.join(File.expand_path(File.dirname(__FILE__)), 'DataFactory')
require File.join(File.expand_path(File.dirname(__FILE__)), '../entity/Application')
require File.join(File.expand_path(File.dirname(__FILE__)), '../entity/Target')
require File.join(File.expand_path(File.dirname(__FILE__)), '../helpers/Cache')
require File.join(File.expand_path(File.dirname(__FILE__)), '../dao/ServerDAO')

class TargetDAO
	def initialize
		@key = 'data:normalizada:target'
        	@ret = Cache.new().cache_data?(@key, self)
        end

        def map
		ret = {}
                data = JSON.parse(Cache.new().cache?('data:application','@fields.tipo:"APPLICATION"'))
                objects = {}

		data.each do |d|
                	desc = d["_source"]["@fields"]["target"][0]
                        env = d["_source"]["@fields"]["ambiente"][0]
                        as = d["_source"]["@fields"]["servidor"][0]
                        server = d["_source"]["@fields"]["instance"][0]
                        application = d["_source"]["@fields"]["app"][0]
                        host = d["_source"]["@fields"]["host"][0]
			key = "TARGET:#{desc}:#{env}:#{as}"
                        id = Digest::SHA256.hexdigest(key)

			objects[key] ||= {}
                        objects[key][:id] = id
                        objects[key][:host] = host
			
			objects[key][:application] ||= []
			objects[key][:application] << application

			objects[key][:server] ||= []
                        objects[key][:server] << { :desc => server, :host => host }

                        objects[key][:server].uniq!
                        objects[key][:application].uniq!
                end

		objects.each do |obj|
                        target = obj[0].split(':')[1]
                        env  = obj[0].split(':')[2]
                        as  = obj[0].split(':')[3]
			id = obj[1][:id]

                        applications = []
                        servers = []

                        obj[1][:application].each do |a| 
				_key = "APPLICATION" << ":#{a}" << ":#{env}:#{as}"
				_id = Digest::SHA256.hexdigest(_key)
				applications << { :id => _id, :desc => a }
			end

                        obj[1][:server].each do |a| 
				_key = "SERVER" << ":#{a[:desc]}" << ":#{env}:#{as}:#{a[:host]}"
				_id = Digest::SHA256.hexdigest(_key)
				#servers << { :id => _id, :desc => a[:desc], :host => a[:host] }
				servers << ServerDAO.new().select(_id)[0]
			end

                        ob = Target.new(id, target, env, as, servers, applications)
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
	
	def purge(id)
                Cache.new().purge_from_historical_data(@key, id)
                return [] << true
        end
end
