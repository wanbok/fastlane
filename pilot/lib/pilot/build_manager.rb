module Pilot
  class BuildManager < Manager
    def upload(options)
      start(options)

      UI.user_error!("No ipa file given") unless config[:ipa]

      UI.success("Ready to upload new build to TestFlight (App: #{app.apple_id})...")

      plist = FastlaneCore::IpaFileAnalyser.fetch_info_plist_file(config[:ipa]) || {}
      platform = plist["DTPlatformName"]
      platform = "ios" if platform == "iphoneos" # via https://github.com/fastlane/spaceship/issues/247
      package_path = FastlaneCore::IpaUploadPackageBuilder.new.generate(app_id: app.apple_id,
                                                                      ipa_path: config[:ipa],
                                                                  package_path: "/tmp",
                                                                      platform: platform)

      transporter = FastlaneCore::ItunesTransporter.new(options[:username])
      result = transporter.upload(app.apple_id, package_path)

      if result
        UI.message("Successfully uploaded the new binary to iTunes Connect")

        unless config[:skip_submission]
          uploaded_build = wait_for_processing_build
          distribute_build(uploaded_build, options)

          UI.message("Successfully distributed build to beta testers 🚀")
        end
      else
        UI.user_error!("Error uploading ipa file, more information see above")
      end
    end

    def list(options)
      start(options)
      if config[:apple_id].to_s.length == 0 and config[:app_identifier].to_s.length == 0
        config[:app_identifier] = ask("App Identifier: ")
      end

      builds = app.all_processing_builds + app.builds
      # sort by upload_date
      builds.sort! {|a, b| a.upload_date <=> b.upload_date }
      rows = builds.collect { |build| describe_build(build) }

      puts Terminal::Table.new(
        title: "#{app.name} Builds".green,
        headings: ["Version #", "Build #", "Testing", "Installs", "Sessions"],
        rows: rows
      )
    end

    private

    def describe_build(build)
      row = [build.train_version,
             build.build_version,
             build.testing_status,
             build.install_count,
             build.session_count]

      return row
    end

    # This method will takes care of checking for the processing builds every few seconds
    # @return [Build] The build that we just uploaded
    def wait_for_processing_build
      # the upload date of the new buid
      # we use it to identify the build

      start = Time.now
      wait_processing_interval = config[:wait_processing_interval].to_i
      latest_build = nil
      loop do
        UI.message("Waiting for iTunes Connect to process the new build")
        sleep wait_processing_interval
        builds = app.all_processing_builds
        break if builds.count == 0
        latest_build = builds.last # store the latest pre-processing build here
      end

      full_build = nil

      while full_build.nil? || full_build.processing
        # Now get the full builds with a reference to the application and more
        # As the processing build from before doesn't have a refernece to the application
        full_build = app.build_trains[latest_build.train_version].builds.find do |b|
          b.build_version == latest_build.build_version
        end

        UI.message("Waiting for iTunes Connect to finish processing the new build (#{full_build.train_version} - #{full_build.build_version})")
        sleep wait_processing_interval
      end

      if full_build
        minutes = ((Time.now - start) / 60).round
        UI.success("Successfully finished processing the build")
        UI.message("You can now tweet: ")
        UI.important("iTunes Connect #iosprocessingtime #{minutes} minutes")
        return full_build
      else
        UI.user_error!("Error: Seems like iTunes Connect didn't properly pre-process the binary")
      end
    end

    def distribute_build(uploaded_build, options)
      UI.message("Distributing new build to testers")

      # First, set the changelog (if necessary)
      uploaded_build.update_build_information!(whats_new: options[:changelog])

      # Submit for review before external testflight is available
      if options[:distribute_external]
        uploaded_build.client.submit_testflight_build_for_review!(
          app_id: uploaded_build.build_train.application.apple_id,
          train: uploaded_build.build_train.version_string,
          build_number: uploaded_build.build_version,
          platform: uploaded_build.platform
        )
      end

      # Submit for beta testing
      type = options[:distribute_external] ? 'external' : 'internal'
      uploaded_build.build_train.update_testing_status!(true, type, uploaded_build)
      return true
    end
  end
end
