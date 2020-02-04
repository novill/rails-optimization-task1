# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

def parse_user(fields)
  {
      'id' => fields[1],
      'first_name' => fields[2],
      'last_name' => fields[3],
      'age' => fields[4],
  }
end

def parse_session(fields)
  {
      'user_id' => fields[1],
      'session_id' => fields[2],
      'browser' => fields[3],
      'time' => fields[4],
      'date' => fields[5],
  }
end

def collect_stats_from_users(report, users_objects, &block)
  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']} #{user.attributes['last_name']}"
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key] = report['usersStats'][user_key].merge(block.call(user))
  end
end

def load_from_file(source_data_file)

  file_lines = File.read(source_data_file).split("\n").map{ |s| s.split(',') }

  # users = []
  # sessions = []

  grouped_file_lines = file_lines.group_by{ |line| line[0] }

  users = grouped_file_lines['user'].map{ |fields| parse_user(fields) }

  sessions = grouped_file_lines['session'].map{|fields| parse_session(fields) }

  # file_lines.each do |line|
  #   if line[0] == 'user'
  #     users = users + [parse_user(line)]
  #   elsif line[0] == 'session'
  #     sessions = sessions + [parse_session(line)]
  #   end
  # end

  [users, sessions]
end

def make_user_objects(users, sessions)
  users_objects = []

  grouped_sessions = sessions.group_by{ |s| s['user_id'] }

  users.each do |user|
    attributes = user
    user_sessions = grouped_sessions[user['id']] || []
    user_object = User.new(attributes: attributes, sessions: user_sessions)
    users_objects = users_objects + [user_object]
  end
  users_objects
end

def work(source_data_file = 'data.txt', disable_gc = false)
  puts 'Start work'

  GC.disable if disable_gc

  users, sessions = load_from_file(source_data_file)

  # Отчёт в json
  #   - Сколько всего юзеров +
  #   - Сколько всего уникальных браузеров +
  #   - Сколько всего сессий +
  #   - Перечислить уникальные браузеры в алфавитном порядке через запятую и капсом +
  #
  #   - По каждому пользователю
  #     - сколько всего сессий +
  #     - сколько всего времени +
  #     - самая длинная сессия +
  #     - браузеры через запятую +
  #     - Хоть раз использовал IE? +
  #     - Всегда использовал только Хром? +
  #     - даты сессий в порядке убывания через запятую +

  report = {}

  report[:totalUsers] = users.count

  # Подсчёт количества уникальных браузеров
  uniqueBrowsers = sessions.map{ |session| session['browser'] }.uniq

  report['uniqueBrowsersCount'] = uniqueBrowsers.count

  report['totalSessions'] = sessions.count

  report['allBrowsers'] =
      sessions
          .map { |s| s['browser'] }
          .map { |b| b.upcase }
          .sort
          .uniq
          .join(',')

  # Статистика по пользователям
  users_objects = make_user_objects(users, sessions)

  report['usersStats'] = {}


  collect_stats_from_users(report, users_objects) do |user|
    prep_sessions = user.sessions.map{ |s|
      [s['time'].to_i,
       s['browser'].upcase,
       Date.parse(s['date'])
      ]
    }
    { 'sessionsCount' => user.sessions.count ,
      'totalTime' => prep_sessions.sum(&:first).to_s + ' min.',
      'longestSession' => prep_sessions.max{ |a, b| a[0] <=> b[0] }[0].to_s + ' min.',
      'browsers' => prep_sessions.map {|ps| ps[1]}.sort.join(', '),
      'usedIE' => prep_sessions.any? { |b| b[1].start_with?('INTERNET EXPLORER') },

      'alwaysUsedChrome' => prep_sessions.all? { |b| b[1].start_with?('CHROME') },
      'dates' => prep_sessions.map {|d| d[2].iso8601 }.sort.reverse
    }
  end

  puts 'Finish work'
  File.write('result.json', "#{report.to_json}\n")
end