Sequel.migration do
  up do
    db = self
    create_table(:accounts) do
      primary_key :id, :type=>:Bignum
      Integer     :status_id, :null=>false, :default => 1, :limit => 2
      String      :email, :null=>false
      index       :email, :unique=>true
    end

    create_table(:account_password_hashes) do
      foreign_key :id, :accounts, :primary_key=>true, :type=>:Bignum
      String      :password_hash, :null=>false
    end

    # Used by the password reset feature
    create_table(:account_password_reset_keys) do
      foreign_key :id, :accounts, :primary_key=>true, :type=>:Bignum
      String      :key, :null=>false
      DateTime    :deadline
      DateTime    :email_last_sent, :null=>false, :default=>Sequel::CURRENT_TIMESTAMP
    end

    # Used by the lockout feature
    create_table(:account_login_failures) do
      foreign_key :id, :accounts, :primary_key=>true, :type=>:Bignum
      Integer     :number, :null=>false, :default=>1
    end
    create_table(:account_lockouts) do
      foreign_key :id, :accounts, :primary_key=>true, :type=>:Bignum
      String      :key, :null=>false
      DateTime    :deadline
      DateTime    :email_last_sent
    end

    # Used by the otp feature
    create_table(:account_otp_keys) do
      foreign_key :id, :accounts, :primary_key=>true, :type=>:Bignum
      String      :key, :null=>false
      Integer     :num_failures, :null=>false, :default=>0
      Time        :last_use, :null=>false, :default=>Sequel::CURRENT_TIMESTAMP
    end

    # Used by the recovery codes feature
    create_table(:account_recovery_codes) do
      foreign_key :id, :accounts, :type=>:Bignum
      String      :code
      primary_key [:id, :code]
    end
  end

  down do
    drop_table(
      :account_recovery_codes,
      :account_otp_keys,
      :account_lockouts,
      :account_login_failures,
      :account_password_reset_keys,
      :account_password_hashes,
      :accounts,
    )
  end
end