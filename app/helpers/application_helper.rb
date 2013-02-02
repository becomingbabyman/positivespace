module ApplicationHelper
	def tb_alert_name name
		tb_names = {'notice' => 'success'}
		tb_names[name.to_s] || name.to_s
	end
end
