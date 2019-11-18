# frozen_string_literal: true

require 'rspec'
require 'spec_helper'
require 'yaml'

describe 'kube_controller_manager' do
  let(:link_spec) do
    {
      'kube-common-config' => {
        'instances' => [],
        'properties' => {
          'tls-cipher-suites' => 'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384'
        }
      }
    }
  end

  it 'has default tls-cipher-suites' do
    kube_scheduler = compiled_template(
      'kube-scheduler',
      'config/bpm.yml',
      {},
      link_spec)

    bpm_yml = YAML.safe_load(kube_scheduler)
    expect(bpm_yml['processes'][0]['args']).to include('--tls-cipher-suites=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384')
  end

  it 'rejects invalid tls-cipher-suites' do
    link_spec["kube-common-config"]["properties"]["tls-cipher-suites"] = 'INVALID_CIPHER'
    expect {
      compiled_template(
      'kube-scheduler',
      'config/bpm.yml',
      {},
      link_spec)
    }.to raise_error(/invalid tls-cipher-suites \(INVALID_CIPHER\)/)
  end
end