class Holiday < ActiveRecord::Base
  unloadable
  belongs_to :user

  with_options presence: true, date: true do
    validates :start
    validates :end
  end
  validate :validate_holiday

  def validate_holiday
    errors.add(:end, :greater_than_start) if self.start && self.end && (self.end < self.start)
  end

  def holidays
    (self.start.to_date..self.end.to_date).select(&:workday?)
  end

  def self.grouped_holidays_by_user(holidays)
    holidays.group_by(&:user)
  end

  def self.grouped_holidays_by_year(holidays)
    holidays.each_with_object({}) do |holiday, result|
      holiday.holidays.each do |day|
        result[day.year] ||= []
        result[day.year] << day
      end
    end
  end

  def self.get_activated_users
    if Setting.plugin_mega_calendar['displayed_type'] == 'users'
      User.where("users.id IN (?) AND users.login IS NOT NULL AND users.login <> ''", Setting.plugin_mega_calendar['displayed_users']).order('users.login ASC')
    else
      User.where("users.id IN (SELECT user_id FROM groups_users WHERE group_id IN (?)) AND users.login IS NOT NULL AND users.login <> ''", Setting.plugin_mega_calendar['displayed_users']).order('users.login ASC')
    end
  end

  def self.get_activated_groups
    if Setting.plugin_mega_calendar['displayed_type'] != 'users'
      Group.where('users.id IN (?)', Setting.plugin_mega_calendar['displayed_users']).order('users.lastname ASC')
    else
      Group.order('users.lastname ASC')
    end
  end
end
