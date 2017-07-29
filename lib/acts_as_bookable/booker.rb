module ActsAsBookable
  module Booker
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      ##
      # Make a model a booker. This allows an instance of a model to claim ownership
      # of bookings.
      #
      # Example:
      #   class User < ActiveRecord::Base
      #     acts_as_booker
      #   end
      def acts_as_booker(opts={})
        class_eval do
          has_many :bookings, as: :booker, dependent: :destroy, class_name: '::ActsAsBookable::Booking'
        end

        include ActsAsBookable::Booker::InstanceMethods
        extend ActsAsBookable::Booker::SingletonMethods
      end

      def booker?
        false
      end
    end

    module InstanceMethods
      ##
      # Book a bookable model
      #
      # @param bookable The resource that will be booked
      # @return The booking created
      # @raise ActsAsBookable::OptionsInvalid if opts are not valid for given bookable
      # @raise ActsAsBookable::AvailabilityError if the bookable is not available for given options
      # @raise ActiveRecord::RecordInvalid if trying to create an invalid booking
      #
      # Example:
      #   @user.book!(@room)
      def book!(bookable, opts={})
        # check availability
        puts opts
        puts 1
        bookable.check_availability!(opts) if bookable.class.bookable?
        puts 2

        # create the new booking
        booking_params = opts.merge({booker: self, bookable: bookable})
        puts 3
        booking = ActsAsBookable::Booking.create!(booking_params)
        puts 4

        # reload the bookable to make changes available
        bookable.reload
        puts 5
        self.reload
        puts 6
        booking
        puts 7
      end

      def booker?
        self.class.booker?
      end
    end

    module SingletonMethods
      def booker?
        true
      end
    end
  end
end
