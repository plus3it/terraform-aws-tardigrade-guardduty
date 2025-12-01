variable "member" {
  description = "GuardDuty member"
  type = object({
    account_id                 = string
    email                      = string # (Required) Email address for member account.
    invitation_message         = string # (Optional) Message for invitation.
    disable_email_notification = bool   # (Optional) Boolean whether an email notification is sent to the accounts. Defaults to false.
  })
}
