# Propshaft expects compiled files in app/assets/builds (gitignored). HTML
# integration tests fail without application.js and application.css.
module EnsureTestAssets
  BUILD_NAMES = %w[application.js application.css].freeze

  module_function

  def call
    return if assets_present?

    build_with_yarn! if yarn_available?

    return if assets_present?

    abort instructions
  end

  def assets_present?
    BUILD_NAMES.all? { |name| File.exist?(build_path(name)) }
  end

  def build_path(name)
    Rails.root.join("app/assets/builds", name)
  end

  def yarn_available?
    !yarn_executable.nil?
  end

  def yarn_executable
    return @yarn_executable if defined?(@yarn_executable)

    @yarn_executable = if system({ out: File::NULL, err: File::NULL }, "which", "yarn")
      "yarn"
    elsif File.executable?("/usr/local/node/bin/yarn")
      "/usr/local/node/bin/yarn"
    end
  end

  def build_with_yarn!
    yarn = yarn_executable
    puts "Building test assets (app/assets/builds)..."
    system(yarn, "build", exception: true)
    system(yarn, "build:css", exception: true)
  end

  def instructions
    <<~MSG

      Missing compiled assets required for HTML tests:
        #{BUILD_NAMES.map { |name| build_path(name) }.join("\n    ")}

      Build them with:
        yarn build && yarn build:css

      Or in Docker (assets service):
        docker compose run --rm --no-deps assets bash -lc 'yarn build && yarn build:css'

      Then re-run: bin/rails test
    MSG
  end
end

EnsureTestAssets.call
