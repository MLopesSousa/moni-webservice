class Target
        attr_accessor :id, :desc, :env, :as, :application, :server

        def initialize(id, desc, env, as, server, application)
		@id = id
                @desc = desc
		@env = env
		@as = as
                @server = server
		@application = application
        end

        def to_s
                return { :id => @id,  :desc => @desc, :env => @env, :as => @as, :server => @server, :application => @application }
        end
end
