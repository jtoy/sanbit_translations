namespace :translation do
  desc 'update useless keys hidden to be true in the database.'

  task :hide_keys => :environment do
    
    puts "Starting update useless keys to hidden=true in the database ..."
    
    TranslationKey.all.each do |tk|
      pattern = /^date\.|^time\.|^datetime\.|^number\.|^support\.|^activerecord\.|^active_scaffold\./
      TranslationKey.connection.execute "UPDATE translation_keys SET hidden = true WHERE id = #{tk.id};" if !tk.hidden && !!(tk.key.match pattern) 
    end
    
    puts "Update done"
  end
end