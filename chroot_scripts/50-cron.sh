echo '=== Cleaning up Cron ==='
sudo rm /etc/cron.hourly/*
sudo rm /etc/cron.daily/*
sudo rm /etc/cron.weekly/*
sudo rm /etc/cron.monthly/*
sudo rm /etc/cron.yearly/*

echo '=== Setting cron.d executable ==='
sudo chmod +x /etc/cron.d/*
