module Workaholic
  module Actor
    def self.included(klass)
      if Workaholic.const_defined?("TestActor")
        klass.__send__(:include, TestActor::InstanceMethods)
        klass.__send__(:extend, TestActor::ClassMethods)
      else
        klass.__send__(:include, Celluloid)
      end
    end
  end
end