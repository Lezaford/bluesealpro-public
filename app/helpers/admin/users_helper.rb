module Admin::UsersHelper
  def role_badge_class(role)
    case role
    when "owner"
      "badge-warning"
    when "admin"
      "badge-info"
    when "tech"
      "badge-success"
    when "viewer"
      "badge-ghost"
    else
      "badge-gray"
    end
  end
end
