require 'oj'
require 'date'

def parse_user(fields)
  {
      'id' => fields[1],
      'name' => "#{fields[2]} #{fields[3]}"
  }
end

def parse_session(fields)
  {
      # 'user_id' => fields[1],
      'browser' => fields[3].upcase,
      'time' => fields[4].to_i,
      'date' => fields[5]
  }
end

def load_objects(source_data_file)
  grouped_file_lines = File.read(source_data_file).split("\n").map { |s| s.split(',') }.group_by { |line| line[0] }

  sessions = grouped_file_lines['session'].map { |fields| [fields[1], parse_session(fields)] }

  grouped_sessions = sessions.group_by { |s| s[0] }

  [ grouped_file_lines['user'].
      map { |fields| {attributes: parse_user(fields), sessions: grouped_sessions[fields[1]] } },
    sessions]
end

def get_user_stats(users_objects)
  users_objects.map do |user|
    times, browsers, dates = *user[:sessions].map{ |s| [s[1]['time'], s[1]['browser'], s[1]['date'] ] }.transpose

    [
      user[:attributes]['name'],
      { 'sessionsCount' => times.size,
        'totalTime' => "#{times.sum} min.",
        'longestSession' => "#{times.max} min.",
        'browsers' => browsers.sort.join(', '),
        'usedIE' => browsers.any?{ |b| b.start_with?('INTERNET EXPLORER') },

        'alwaysUsedChrome' => browsers.all?{ |b| b.start_with?('CHROME') },
        'dates' => dates.sort.reverse
      }
    ]
  end
end

def work(source_data_file = 'data.txt', disable_gc = false)
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

  report['totalUsers'] = users_objects.size

  # Подсчёт количества уникальных браузеров
  uniqueBrowsers = sessions.map { |session| session[1]['browser'] }.uniq

  report['uniqueBrowsersCount'] = uniqueBrowsers.count

  report['totalSessions'] = sessions.count

  report['allBrowsers'] = sessions.map { |s| s[1]['browser'] }.uniq!.sort.join(',').upcase

  # Статистика по пользователям

  report['usersStats'] = get_user_stats(users_objects).to_h

  File.write('result.json', Oj.dump(report)+"\n")
end































