# ####################################### Cognito User Pool Configuration #######################################
# # Creates a Cognito User Pool to manage user authentication.
# # The User Pool provides secure user registration, sign-in, and account recovery features.

# resource "aws_cognito_user_pool" "user_pool" {
#   name = "multi-tier-app-user-pool" # Name of the User Pool

#   # Password policy to enforce strong passwords.
#   password_policy {
#     minimum_length    = 8    # Minimum length of the password
#     require_lowercase = true # Require at least one lowercase letter
#     require_uppercase = true # Require at least one uppercase letter
#     require_numbers   = true # Require at least one numeric character
#     require_symbols   = true # Require at least one special character
#   }

#   # Automatically verify user emails upon sign-up.
#   auto_verified_attributes = ["email"] # List of attributes to auto-verify

#   # Configure account recovery via verified email.
#   account_recovery_setting {
#     recovery_mechanism {
#       name     = "verified_email" # Recovery mechanism type
#       priority = 1                # Priority of this recovery mechanism
#     }
#   }

# }

# ####################################### Cognito User Pool Client Configuration #######################################
# # Creates a User Pool Client to enable applications to interact with the User Pool.
# # This client allows users to sign in and retrieve tokens.

# resource "aws_cognito_user_pool_client" "user_pool_client" {
#   name                = "multi-tier-app-client"                                  # Name of the User Pool Client
#   user_pool_id        = aws_cognito_user_pool.user_pool.id                       # Reference to the User Pool ID
#   generate_secret     = false                                                    # Whether to generate a client secret
#   explicit_auth_flows = ["ALLOW_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"] # Supported authentication flows

# }

# ####################################### Cognito Identity Pool Configuration #######################################
# # Creates an Identity Pool to grant users access to AWS services.
# # This pool links the User Pool for user authentication with AWS services access.

# resource "aws_cognito_identity_pool" "identity_pool" {
#   identity_pool_name               = "multi-tier-app-identity-pool" # Name of the Identity Pool
#   allow_unauthenticated_identities = false                          # Restricts access to authenticated users only

#   # Link the Cognito User Pool to the Identity Pool.
#   cognito_identity_providers {
#     client_id               = aws_cognito_user_pool_client.user_pool_client.id                                    # Reference to User Pool Client ID
#     provider_name           = "cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.user_pool.id}" # Provider name
#     server_side_token_check = true                                                                                # Enable server-side token validation
#   }

# }

# ####################################### IAM Role for Authenticated Users #######################################
# # Creates an IAM Role for authenticated users to access AWS resources.
# # This role defines permissions for the users authenticated through the Identity Pool.

# resource "aws_iam_role" "authenticated_role" {
#   name = "Cognito_Authenticated_Role" # Name of the IAM Role

#   # Trust policy to allow Cognito Identity Pool to assume this role.
#   assume_role_policy = jsonencode({
#     "Version" : "2012-10-17",
#     "Statement" : [
#       {
#         "Effect" : "Allow",
#         "Principal" : {
#           "Federated" : "cognito-identity.amazonaws.com" # Trusts the Cognito Identity service
#         },
#         "Action" : "sts:AssumeRoleWithWebIdentity", # Action to assume the role
#         "Condition" : {
#           "StringEquals" : {
#             "cognito-identity.amazonaws.com:aud" : aws_cognito_identity_pool.identity_pool.id # Condition to match the Identity Pool ID
#           },
#           "ForAnyValue:StringLike" : {
#             "cognito-identity.amazonaws.com:amr" : "authenticated" # Condition to allow authenticated users
#           }
#         }
#       }
#     ]
#   })

# }

# ####################################### IAM Role Policy for Access to AWS Services #######################################
# # Defines a policy granting access to specific AWS services for authenticated users.

# resource "aws_iam_role_policy" "access_aws_services" {
#   name = "access_aws_services"              # Name of the IAM Role Policy
#   role = aws_iam_role.authenticated_role.id # Reference to the IAM Role ID
#   policy = jsonencode({
#     "Version" : "2012-10-17",
#     "Statement" : [
#       {
#         "Effect" : "Allow",
#         "Action" : [
#           "s3:ListBucket",  # Allow listing S3 buckets
#           "s3:GetObject",   # Allow getting objects from S3
#           "dynamodb:Query", # Allow querying DynamoDB
#           "dynamodb:Scan"   # Allow scanning DynamoDB
#         ],
#         "Resource" : "*" # Resources to which this policy applies
#       }
#     ]
#   })

# }

# ####################################### Attach IAM Roles to the Identity Pool #######################################
# # Associates the IAM Role with the Cognito Identity Pool to manage user permissions.

# resource "aws_cognito_identity_pool_roles_attachment" "identity_pool_roles" {
#   identity_pool_id = aws_cognito_identity_pool.identity_pool.id # Reference to the Identity Pool ID

#   roles = {
#     "authenticated" = aws_iam_role.authenticated_role.arn # IAM Role ARN for authenticated users
#   }

# }

# ####################################### Social Identity Providers Configuration #######################################
# # Example: Configuring social identity providers (Google, Facebook) for user authentication.

# # Uncomment to configure Google as an identity provider.
# # resource "aws_cognito_identity_provider" "google" {
# #   user_pool_id   = aws_cognito_user_pool.user_pool.id
# #   provider_name  = "Google"
# #   provider_type  = "Google"

# #   provider_details = {
# #     client_id       = var.google_client_id         # Client ID for Google
# #     client_secret   = var.google_client_secret     # Client Secret for Google
# #     authorize_scopes = "openid email profile"      # Scopes for Google
# #   }

# #   attribute_mapping = {
# #     email    = "email"   # Mapping email attribute
# #     username = "sub"     # Mapping username attribute
# #   }
# # }

# # Uncomment to configure Facebook as an identity provider.
# # resource "aws_cognito_identity_provider" "facebook" {
# #   user_pool_id  = aws_cognito_user_pool.user_pool.id
# #   provider_name = "Facebook"
# #   provider_type = "Facebook"

# #   provider_details = {
# #     client_id       = var.facebook_app_id        # App ID for Facebook
# #     client_secret   = var.facebook_app_secret    # App Secret for Facebook
# #     authorize_scopes = "email public_profile"    # Scopes for Facebook
# #   }

# #   attribute_mapping = {
# #     email    = "email"    # Mapping email attribute
# #     username = "id"       # Mapping username attribute
# #   }
# # }
