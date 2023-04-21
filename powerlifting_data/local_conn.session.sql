ALTER TABLE powerlift_data
RENAME TO powerlift_backup;

ALTER TABLE with_temp_id
RENAME TO powerlift_data;