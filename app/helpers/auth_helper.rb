module AuthHelper
  INPUT_CLASS = [
    "block w-full rounded-lg border-0 px-3.5 py-2.5 text-gray-900",
    "shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400",
    "focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6"
  ].join(" ").freeze

  LABEL_CLASS = "block text-sm font-medium leading-6 text-gray-900".freeze

  BTN_PRIMARY_CLASS = [
    "flex w-full justify-center rounded-lg bg-indigo-600 px-3 py-2.5",
    "text-sm font-semibold text-white shadow-sm hover:bg-indigo-500",
    "focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2",
    "focus-visible:outline-indigo-600 disabled:opacity-60 disabled:cursor-not-allowed"
  ].join(" ").freeze

  BTN_SECONDARY_CLASS = [
    "flex w-full justify-center rounded-lg bg-white px-3 py-2.5",
    "text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300",
    "hover:bg-gray-50"
  ].join(" ").freeze

  LINK_CLASS = "font-semibold text-indigo-600 hover:text-indigo-500".freeze
end
