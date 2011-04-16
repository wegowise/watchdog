Description
===========

Watchdog ensures your extensions and monkey patches don't redefine existing methods as well as get redefined by others.

Install
=======

    $ gem install watchdog

Usage
=====

Let's say we want to add an instance method to String with extension module ToDate:

    module ToDate
      def to_date
        Date.parse(self)
      end
    end

    String.send :include, ToDate

What happens if String#to_date already exists? What happens if another gem redefines that method
later? Breakage.

Watchdog watches over these concerns with a simple extend:

    module ToDate
      extend Watchdog

      def to_date
        Date.parse(self)
      end
    end

    String.send :include, ToDate

Now if String#to_date already exists, watchdog raises a runtime error. Same goes if someone tries to
redefine the method later:

    >> class String; def to_date; p 'HAHAHA'; end; end
    Watchdog::ExtensionMethodExistsError: Date not allowed to redefine extension method from ToDate#to_date
        ./lib/watchdog.rb:13:in `guard'
        ./lib/watchdog/german_shepard.rb:23:in `method_added'
        (ripl):3

Watchdog also guards over extension modules that define class methods:


    module DaysTillXmas
      extend Watchdog

      def days_till_xmas
        Date.new(Date.today.year, 12, 25) - Date.today
      end
    end

    Date.extend DaysTillXmas
    # Date.days_till_xmas ->  253  NOOOO...

Credits
=======

Thanks to Wegowise for open-source time to make this possible!


License
=======

See LICENSE file
