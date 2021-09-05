package MasterWebInterface;

our %S = (%S, # retain options from parent script
  
  # site info
  site_url  => "http://master.333networks.com",
  site_name => "333networks",
  email     => 'master@333networks.com',
  
  # database connection
  db_login  => ["dbi:SQLite:dbname=/path/to/your/data/masterserver.db",'',''],
  
  # display
  style     => "default",
  
  # do not display servers older than [seconds]
  window_time => 1800,
);

1;
