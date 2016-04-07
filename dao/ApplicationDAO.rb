require 'digest'

require File.join(File.expand_path(File.dirname(__FILE__)), 'DataFactory')
require File.join(File.expand_path(File.dirname(__FILE__)), '../entity/Application')
require File.join(File.expand_path(File.dirname(__FILE__)), '../entity/Target')
require File.join(File.expand_path(File.dirname(__FILE__)), '../helpers/Cache')
require File.join(File.expand_path(File.dirname(__FILE__)), '../dao/TargetDAO')

class ApplicationDAO
	def initialize
		@key = "data:normalizada:application"
                @ret = Cache.new().cache_data?(@key, self)
        end

        def map
		ret = {}
		data = JSON.parse(Cache.new().cache?('data:application','@fields.tipo:"APPLICATION"'))
		objects = {}
                
		data.each do |d|
                        desc = d["_source"]["@fields"]["app"][0]
			env = d["_source"]["@fields"]["ambiente"][0]
                        as = d["_source"]["@fields"]["servidor"][0]
                        target = d["_source"]["@fields"]["target"][0]
			context = d["_source"]["@fields"]["context"][0]
                        key = "APPLICATION:#{desc}:#{env}:#{as}"
                        id = Digest::SHA256.hexdigest(key)

                        objects[key] ||= {}
                        objects[key][:id] = id
                        objects[key][:context] = context

                        objects[key][:target] ||= []
                        objects[key][:target] << target
                        objects[key][:target].uniq!
                end

                objects.each do |obj|
                        app = obj[0].split(':')[1]
                        env = obj[0].split(':')[2]
                        as  = obj[0].split(':')[3]
                        id = obj[1][:id]
                        context = obj[1][:context]

                        targets = []
                        obj[1][:target].each do |a|
				_key = "TARGET" << ":#{a}" << ":#{env}:#{as}"
                                _id = Digest::SHA256.hexdigest(_key)
                                #targets << { :id => _id, :desc => a}
				targets << TargetDAO.new().select(_id)[0]
                        end

                        ob = Application.new(id, app, context, env, as, targets)
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

	def purge_new(id)
		Cache.new().purge_from_new_data(@key, id)
	end
end
