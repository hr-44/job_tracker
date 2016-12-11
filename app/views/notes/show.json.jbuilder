json.note(@note, :id, :user_id, :notable_type, :notable_id, :content, :created_at, :updated_at)

if @notable.class == Contact
  json.contact(@notable)
else
  json.job_application(@notable)
end
