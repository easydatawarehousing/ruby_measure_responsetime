class ApplicationController < ActionController::Base

  before_action :counter

  private

  def counter
    $req_count ||= 0
    $req_count += 1

    $mgcs ||= []
    $last_mgc_count ||= GC.stat[:major_gc_count]
    mgc = GC.stat[:major_gc_count] || GC.stat[:count]

    if $last_mgc_count != mgc
      $mgcs << $req_count
      $last_mgc_count = mgc
    end
  end
end
