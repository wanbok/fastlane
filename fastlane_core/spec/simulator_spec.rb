require 'open3'

describe FastlaneCore do
  describe FastlaneCore::Simulator do
    before do
      @valid_simulators = "== Devices ==
-- iOS 7.1 --
    iPhone 4s (8E3D97C4-1143-4E84-8D57-F697140F2ED0) (Shutdown) (unavailable, failed to open liblaunch_sim.dylib)
    iPhone 5 (65D0F571-1260-4241-9583-611EAF4D56AE) (Shutdown) (unavailable, failed to open liblaunch_sim.dylib)
-- iOS 8.1 --
    iPhone 4s (DBABD2A2-0144-44B0-8F93-263EB656FC13) (Shutdown)
    iPhone 5 (0D80C781-8702-4156-855E-A9B737FF92D3) (Booted)
-- iOS 9.1 --
    iPhone 6s Plus (BB65C267-FAE9-4CB7-AE31-A5D9BA393AF0) (Shutdown)
    Resizable iPad (B323CCB4-840B-4B26-B57B-71681D6C30C2) (Shutdown) (unavailable, device type profile not found)
    iPad Air 2 (961A7DF9-F442-4CA5-B28E-D96288D39DCA) (Shutdown)
-- tvOS 9.0 --
    Apple TV 1080p (D239A51B-A61C-4B60-B4D6-B7EC16595128) (Shutdown)
-- watchOS 2.0 --
    Apple Watch - 38mm (FE0C82A5-CDD2-4062-A62C-21278EEE32BB) (Shutdown)
    Apple Watch - 38mm (66D1BF17-3003-465F-A165-E6E3A565E5EB) (Booted)
"
      FastlaneCore::Simulator.clear_cache
    end

    it "raises an error if xcrun CLI prints garbage" do
      response = "response"
      expect(response).to receive(:read).and_return("💩")
      expect(Open3).to receive(:popen3).with("xcrun simctl list devices").and_yield(nil, response, nil, nil)

      expect do
        devices = FastlaneCore::Simulator.all
      end.to raise_error("xcrun simctl not working.")
    end

    it "properly parses the simctl output and generates Device objects for iOS" do
      response = "response"
      expect(response).to receive(:read).and_return(@valid_simulators)
      expect(Open3).to receive(:popen3).with("xcrun simctl list devices").and_yield(nil, response, nil, nil)

      devices = FastlaneCore::Simulator.all
      expect(devices.count).to eq(4)

      expect(devices[0]).to have_attributes(
        name: "iPhone 4s", os_version: "8.1",
        udid: "DBABD2A2-0144-44B0-8F93-263EB656FC13",
        state: "Shutdown"
      )
      expect(devices[1]).to have_attributes(
        name: "iPhone 5", os_version: "8.1",
        udid: "0D80C781-8702-4156-855E-A9B737FF92D3",
        state: "Booted"
      )
      expect(devices[2]).to have_attributes(
        name: "iPhone 6s Plus", os_version: "9.1",
        udid: "BB65C267-FAE9-4CB7-AE31-A5D9BA393AF0",
        state: "Shutdown"
      )
      expect(devices[3]).to have_attributes(
        name: "iPad Air 2", os_version: "9.1",
        udid: "961A7DF9-F442-4CA5-B28E-D96288D39DCA",
        state: "Shutdown"
      )
    end

    it "properly parses the simctl output and generates Device objects for tvOS" do
      response = "response"
      expect(response).to receive(:read).and_return(@valid_simulators)
      expect(Open3).to receive(:popen3).with("xcrun simctl list devices").and_yield(nil, response, nil, nil)

      devices = FastlaneCore::SimulatorTV.all
      expect(devices.count).to eq(1)

      expect(devices[0]).to have_attributes(
        name: "Apple TV 1080p", os_version: "9.0",
        udid: "D239A51B-A61C-4B60-B4D6-B7EC16595128",
        state: "Shutdown"
      )
    end

    it "properly parses the simctl output and generates Device objects for watchOS" do
      response = "response"
      expect(response).to receive(:read).and_return(@valid_simulators)
      expect(Open3).to receive(:popen3).with("xcrun simctl list devices").and_yield(nil, response, nil, nil)

      devices = FastlaneCore::SimulatorWatch.all
      expect(devices.count).to eq(2)

      expect(devices[0]).to have_attributes(
        name: "Apple Watch - 38mm", os_version: "2.0",
        udid: "FE0C82A5-CDD2-4062-A62C-21278EEE32BB",
        state: "Shutdown"
      )
      expect(devices[1]).to have_attributes(
        name: "Apple Watch - 38mm", os_version: "2.0",
        udid: "66D1BF17-3003-465F-A165-E6E3A565E5EB",
        state: "Booted"
      )
    end
  end
end
