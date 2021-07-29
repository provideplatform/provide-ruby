module Provide
    module Services
      class Vault < Provide::ApiClient
  
        def initialize(scheme = 'http', host, token)
          @scheme = scheme
          @host = host
          @token = token
        end
  
        def create_key(vault_id)
            parse client.post "vaults/#{vault_id}"
        end

        def delete_key(vault_id, key_id)
            parse client.delete "vaults/#{vault_id}/keys/#{key_id}"
        end

        def derive_key(vault_id, key_id)
            parse client.post "vaults/#{vault_id}/keys/#{key_id}/derive"
        end

        def encrypt(vault_id, key_id, data)
            parse client.post "vaults/#{vault_id}/keys/#{key_id}/encrypt", data
        end

        def decrypt(vault_id, key_id, data)
            parse client.post "vaults/#{vault_id}/keys/#{key_id}/decrypt", data
        end

        def list_keys(vault_id)
            parse client.get "vaults/#{vault_id}/keys"
        end

        def list_secrets(vault_id)
            parse client.get "vaults/#{vault_id}/secrets"
        end

        def store_secret(vault_id, secret)
            parse client.post "vaults/#{vault_id}/secrets", secret
        end

        def retrieve_secret(vault_id, secret_id)
            parse client.get "vaults/#{vault_id}/secrets/#{secret_id}"
        end

        def delete_secret(vault_id, secret_id)
            parse client.delete "vaults/#{vault_id}/secrets/#{secret_id}"
        end

        def create_vault(params)
            parse client.post 'vaults', params
        end

        def list_vaults(params = nil)
            parse client.get 'vaults', (params || {})
        end

        private
  
        def client
          @client ||= begin
            Provide::ApiClient.new(@scheme, @host, 'api/v1/', @token)
          end
        end
  
        def parse(response)
          begin
            body = response.code == 204 ? nil : JSON.parse(response.body)
            return response.code, response.headers, body
          rescue
            raise Exception.new({
              :code => response.code,
            })
          end
        end
      end
    end
  end
  