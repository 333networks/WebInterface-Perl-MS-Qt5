package MasterWebInterface;

our %S = (%S, # retain options from parent script
  
  # site (for sharing options)
  site_url  => "https://master.333networks.com",
  site_name => "333networks",
  email     => 'master@333networks.com',
  
  # database connection
  db_login  => ["dbi:SQLite:dbname=/path/to/your/data/masterserver.db",'',''],
  
  # display
  style     => "333networks",
  meta_color  => "#00AAFF",
  
  # do not display servers older than [seconds]
  window_time => 1800,
);

1;
