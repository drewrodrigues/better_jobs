require 'yaml'
require 'colorize'
require_relative 'job_posting'

# manage storage of job postings
class Storage
  attr_reader :matches, :misses

  def initialize
    @matches = YAML.load(File.read('./storage/matches.yml'))
    @misses = YAML.load(File.read('./storage/misses.yml'))
    @matches = {} unless @matches.is_a?(Hash)
    @misses = {} unless @misses.is_a?(Hash)
  end

  def save_jobs(job_postings)
    job_postings.each do |job|
      job.passing_score? ? add_match(job) : add_miss(job)
    end
    save_all
  end

  def add_match(job)
    return nil if already_saved?(job)

    matches[job.id] = job
  end

  def add_miss(job)
    return nil if already_saved?(job)

    misses[job.id] = {
      location: job.location,
      position: job.position,
      url: job.url
    }
  end

  def save_match(job)
    return unless save_match(job)

    File.open('./storage/matches.yml', 'w') { |f| f.write(matches.to_yaml) }
  end

  def save_miss(job)
    return unless add_miss(job)

    File.open('./storage/misses.yml', 'w') { |f| f.write(misses.to_yaml) }
  end

  def already_saved?(job)
    id = job.is_a?(JobPosting) ? job.id : job.attribute('id')
    misses[id] || matches[id]
  end

  def save_matches
    File.open('./storage/matches.yml', 'w') { |f| f.write(matches.to_yaml) }
  end

  def save_misses
    File.open('./storage/misses.yml', 'w') { |f| f.write(misses.to_yaml) }
  end

  def move_from_matches_to_misses(job_posting)
    deleted = matches.reject! { |_, posting| posting == job_posting }
    raise 'Failed to delete match' unless deleted

    misses[job_posting.id] = job_posting
    save_all
  end

  def save_all
    save_matches
    save_misses
  end
end