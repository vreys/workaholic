module Workaholic
  module TestActor
    module ClassMethods
      def trap_exit(*args)
      end
    end

    module InstanceMethods
      def current_actor
        self
      end
      def after(interval)
      end
      def alive?
        !@dead
      end
      def terminate
        @dead = true
      end
    end
  end
end