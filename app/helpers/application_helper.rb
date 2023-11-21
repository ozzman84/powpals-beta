# frozen_string_literal: true

module ApplicationHelper
  def navigation_items
    [
      { body: 'Dashboard', href: user_path },
      { body: 'Lodgings', href: users_lodgings_path },
      { body: 'PowPals', href: users_path }
    ]
  end

  def navigation_class(path)
    if current_page?(path)
      'bg-gray-900 text-white rounded-md px-3 py-2 text-sm font-medium'
    else
      'text-gray-300 hover:bg-gray-700 hover:text-white rounded-md px-3 py-2 text-sm font-medium'
    end
  end

  def navigation_aria(path)
    if current_page?(path)
      'page'
    else
      'false'
    end
  end

  def avatar_class(dimensions = 'h-6 w-6')
    "inline-flex #{dimensions} items-center justify-center rounded-full bg-gray-500"
  end
end
