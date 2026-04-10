resource "aws_identitystore_group" "admins" {
  display_name      = "Administrators"
  description       = "Group for administrators"
  identity_store_id = local.identity_store_id
}

resource "aws_identitystore_user" "johndoe" {
  identity_store_id = local.identity_store_id

  display_name = "Main User"
  user_name    = "main"

  name {
    given_name  = "Main"
    family_name = "User"
  }

  emails {
    value = "${var.base_email}@gmail.com"
  }
}

resource "aws_identitystore_group_membership" "admins_johndoe" {
  identity_store_id = local.identity_store_id
  group_id          = aws_identitystore_group.admins.group_id
  member_id         = aws_identitystore_user.johndoe.user_id
}