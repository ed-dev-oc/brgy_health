class SubdomainConstraint
  def matches?(request)
    request.subdomain.present? && request.subdomain != "www"
  end
end
