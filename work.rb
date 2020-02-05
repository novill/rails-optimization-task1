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

def load_objects(source_data_file)
  grouped_file_lines = File.read(source_data_file).split("\n").map{ |s| s.split(',') }.group_by{ |line| line[0] }

  sessions = grouped_file_lines['session'].map{|fields| parse_session(fields) }

  grouped_sessions = sessions.group_by{ |s| s['user_id'] }

   [ grouped_file_lines['user'].
      map{ |fields| parse_user(fields) }.
      map{ |user| User.new(attributes: user, sessions: grouped_sessions[user['id']]) },
   sessions]
end

def get_user_stats(users_objects)
  users_objects.map { |user|
    prep_sessions = user.sessions.map{ |s| [s['time'].to_i, s['browser'].upcase, s['date'] ] }

    [
        "#{user.attributes['first_name']} #{user.attributes['last_name']}",
        { 'sessionsCount' => user.sessions.size,
          'totalTime' => prep_sessions.sum(&:first).to_s + ' min.',
          'longestSession' => prep_sessions.max{ |a, b| a[0] <=> b[0] }[0].to_s + ' min.',
          'browsers' => prep_sessions.map {|ps| ps[1]}.sort.join(', '),
          'usedIE' => prep_sessions.any? { |b| b[1].start_with?('INTERNET EXPLORER') },

          'alwaysUsedChrome' => prep_sessions.all? { |b| b[1].start_with?('CHROME') },
          'dates' => prep_sessions.map {|d| d[2]}.sort.reverse
        }
    ]
  }
end

def work(source_data_file = 'data.txt', disable_gc = false)
  puts 'Start work'

  GC.disable if disable_gc

  users_objects, sessions = load_objects(source_data_file)

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

  report[:totalUsers] = users_objects.size

  # Подсчёт количества уникальных браузеров
  uniqueBrowsers = sessions.map{ |session| session['browser'] }.uniq

  report['uniqueBrowsersCount'] = uniqueBrowsers.count

  report['totalSessions'] = sessions.count

  report['allBrowsers'] = sessions.map { |s| s['browser'] }.uniq.sort.join(',').upcase

  # Статистика по пользователям

  report['usersStats'] = get_user_stats(users_objects).to_h

  puts 'Finish work'
  File.write('result.json', "#{report.to_json}\n")
end































