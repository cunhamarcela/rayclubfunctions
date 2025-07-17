#!/bin/bash

echo "=== Ray Club App - Script para Simulador ==="
echo "Este script executa o app no simulador iOS sem problemas de flag -G"

# Diretório do projeto
PROJECT_DIR="$(pwd)"
IOS_DIR="${PROJECT_DIR}/ios"
PODFILE="${IOS_DIR}/Podfile"

# Limpar configurações anteriores
echo "🧹 Limpando configurações anteriores..."
flutter clean
cd "${IOS_DIR}" && rm -rf Pods Podfile.lock .symlinks
cd "${PROJECT_DIR}"
flutter pub get

# Backup do Podfile original
if [ ! -f "${PODFILE}.bak" ]; then
  cp "${PODFILE}" "${PODFILE}.bak"
  echo "📝 Backup do Podfile original criado em ${PODFILE}.bak"
fi

# Criar Podfile simplificado para simulador
echo "📝 Criando Podfile simplificado para simulador..."
cat > "${PODFILE}" << 'EOL'
# Uncomment this line to define a global platform for your project
platform :ios, '14.0'

# CocoaPods analytics sends network stats synchronously affecting flutter build latency.
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

# Desativar qualquer flag de Swift que possa causar problemas
ENV['OTHER_SWIFT_FLAGS'] = ENV.fetch('OTHER_SWIFT_FLAGS', '').gsub('-G', '')

project 'Runner', {
  'Debug' => :debug,
  'Profile' => :release,
  'Release' => :release,
}

def flutter_root
  generated_xcode_build_settings_path = File.expand_path(File.join('..', 'Flutter', 'Generated.xcconfig'), __FILE__)
  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist. If you're running pod install manually, make sure flutter pub get is executed first"
  end

  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/FLUTTER_ROOT\=(.*)/)
    return matches[1].strip if matches
  end
  raise "FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}. Try deleting Generated.xcconfig, then run flutter pub get"
end

require File.expand_path(File.join('packages', 'flutter_tools', 'bin', 'podhelper'), flutter_root)

flutter_ios_podfile_setup

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  target 'RunnerTests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  # Remover flags -G em todos os alvos
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    
    target.build_configurations.each do |config|
      # Versão mínima de iOS
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
      
      # Remover flags Swift
      if config.build_settings['OTHER_SWIFT_FLAGS']
        if config.build_settings['OTHER_SWIFT_FLAGS'].is_a?(String)
          config.build_settings['OTHER_SWIFT_FLAGS'] = config.build_settings['OTHER_SWIFT_FLAGS'].gsub(/-G\b/, '')
        elsif config.build_settings['OTHER_SWIFT_FLAGS'].is_a?(Array)
          config.build_settings['OTHER_SWIFT_FLAGS'] = config.build_settings['OTHER_SWIFT_FLAGS'].reject { |flag| flag == '-G' }
        end
      end
      
      # Desabilitar HealthKit para simulador
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)']
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] << 'DISABLE_HEALTHKIT=1'
    end
  end
end
EOL

# Instalar pods
echo "📦 Instalando pods..."
cd "${IOS_DIR}" && pod install --repo-update
cd "${PROJECT_DIR}"

# Criar script para remover flag -G
cat > "${IOS_DIR}/remove_g_flag.rb" << 'EOL'
#!/usr/bin/env ruby

puts "🔍 Removendo flag -G de todos os arquivos de configuração..."

# Caminhos para os diretórios
pods_dir = "#{Dir.pwd}/Pods"
build_dir = "#{Dir.pwd}/build"
runner_dir = "#{Dir.pwd}/Runner"

def process_files(directory, pattern)
  return unless File.directory?(directory)
  
  Dir.glob("#{directory}/**/#{pattern}").each do |file|
    content = File.read(file)
    
    if content.include?("-G")
      new_content = content.gsub(/-G\b/, "")
      File.write(file, new_content)
      puts "✓ #{file}"
    end
  end
end

# Processar diferentes tipos de arquivos
[pods_dir, build_dir, runner_dir, Dir.pwd].each do |dir|
  process_files(dir, "*.xcconfig")
  process_files(dir, "*.pbxproj")
  process_files(dir, "*.h")
  process_files(dir, "*.m")
  process_files(dir, "*.swift")
end

puts "✅ Concluído!"
EOL

chmod +x "${IOS_DIR}/remove_g_flag.rb"
cd "${IOS_DIR}" && ruby remove_g_flag.rb
cd "${PROJECT_DIR}"

# Executar o app no simulador
echo "🚀 Executando o app no simulador..."
flutter run --no-sound-null-safety 