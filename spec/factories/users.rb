FactoryBot.define do
    factory :user, aliases: %i[sender receiver] do
      name { 'mohn' }
      sequence(:email) { |n| "mohn@ex#{n}.com" }
      password { 'password' }
    end
  end