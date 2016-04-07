class Application
        attr_accessor :id, :desc, :context, :env, :target, :as

        def initialize(id, desc, context, env, as, target = [])
		@id = id
                @desc = desc
                @context = context
                @env = env
		@as = as
                @target = target
        end

        def to_s
                return { :id => @id, :desc => @desc, :context => @context, :env => @env, :as => @as, :target => @target }
        end
end
