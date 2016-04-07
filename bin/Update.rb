require 'json'
require 'redis'

require File.join(File.expand_path(File.dirname(__FILE__)), '../dao/ApplicationDAO')
require File.join(File.expand_path(File.dirname(__FILE__)), '../dao/TargetDAO')
require File.join(File.expand_path(File.dirname(__FILE__)), '../dao/ServerDAO')

class Update
	def initialize
		@redis = Redis.new()
	end

	def build_all
		_map = { :ApplicationDAO => 'applications',
			 :TargetDAO => 'targets',
			 :ServerDAO => 'servers'
		}

		_map.each do |k, v|
			#clazz = Object.const_get(k)
			#@redis.set(v, clazz.new().list().to_json)
                	#@redis.expire(v,14400)
		end

		_map.each do |k, v|
			clazz = Object.const_get(k)

			arr = JSON.parse(@redis.get(v))
			arr.each do |ob|
				key = "#{v}-#{ob['desc']}"
				begin
					puts "Populando cache #{v} com o valor: #{key}"
				
					@redis.set(key, clazz.new().select(ob['desc']).to_json)
					@redis.expire(key,14400)
				rescue
					puts "Erro ao populando cache #{v} com o valor: #{key}"
				end
			end
		end
	end
end
Update.new().build_all()
