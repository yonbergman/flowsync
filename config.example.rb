class Flowsync

  module Config
    # First Fill these config params
    TOKEN         = "YOUR-MAIN-API-TOKEN-(YOURS)"
    ORGANIZATION  = "YOUR-ORGANIZATION-NAME"
    FLOWS         = %w(list_of_flows the_first_one_is_the_main_flow)

    # Run once and we will publish an empty users list to fill in the first flow
    USERS = {}
  end

end