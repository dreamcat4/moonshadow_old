

# Return a binding which an includes method for each symbol key in hash, which,
# when called, forwards to the instance method from instance with the name from
# the key's symbol value.
#
# In other words, ERB(blah).result(methods_from_instance_methods(f, :x => :y))
# will give ERB a method x(args), which, when called, returns f.y(args).
def methods_from_instance_methods instance, hash
    InstanceMethodsToMethods.new(instance, hash).instance_eval { binding }
end

class InstanceMethodsToMethods < Module
    def initialize instance, hash
        @instance_for_methods = instance
        super() do
            hash.each do | k, v |
                self.class.send :define_method, k do | *args |
                    @instance_for_methods.send v, *args
                end
            end
        end
    end
end
