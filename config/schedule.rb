set :output, "/home/deployer/apps/eo/current/log/cron.log"

every :day, at: "3:00 AM" do
  runner "Invoice.apply_addons"
end