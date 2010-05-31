=begin

This file is part of the shikashi project, http://github.com/tario/shikashi

Copyright (c) 2009-2010 Roberto Dario Seminara <robertodarioseminara@gmail.com>

shikashi is free software: you can redistribute it and/or modify
it under the terms of the gnu general public license as published by
the free software foundation, either version 3 of the license, or
(at your option) any later version.

shikashi is distributed in the hope that it will be useful,
but without any warranty; without even the implied warranty of
merchantability or fitness for a particular purpose.  see the
gnu general public license for more details.

you should have received a copy of the gnu general public license
along with shikashi.  if not, see <http://www.gnu.org/licenses/>.

=end

require "rallhook"
require "shikashi/privileges"

module Shikashi

  class << self
    attr_accessor :global_binding
  end

  class Sandbox

    attr_accessor :privileges

    def initialize
      @privileges = Shikashi::Privileges.new

      @privileges.allow_method :eval
      @privileges.allow_exceptions
    end

    def self.generate_id
      "sandbox-#{rand(1000000)}"
    end

    class RallhookHandler < RallHook::HookHandler
      attr_accessor :sandbox
      def handle_method(klass, recv, method_name, method_id)
        unless sandbox.privileges.allow?(klass,recv,method_name,method_id)
          raise SecurityError.new("Cannot invoke method #{method_name} over #{recv}")
        end
        nil
      end
    end

    #
    # Run the code in sandbox with the given privileges
    #
    def run(code , alternative_binding = nil)
      source = Sandbox.generate_id
      handler = RallhookHandler.new
      handler.sandbox = self
      alternative_binding = alternative_binding || Shikashi.global_binding
      handler.hook do
        eval(code, alternative_binding, source)
      end
    end
  end
end

Shikashi.global_binding = binding()

