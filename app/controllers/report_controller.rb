class ReportController < ApplicationController
  layout "default"
  before_action :set_dates
  helper :user

  def tag_updates
    @users = Report.tag_updates(@start_date, @end_date, @limit, @level)
    @report_title = "Tag Updates"
    @change_params = lambda { |user_id| { :controller => "history", :action => "index", :search => "type:post user:#{User.find(user_id).name}" } }
    render :action => "common"
  end

  def note_updates
    @users = Report.note_updates(@start_date, @end_date, @limit, @level)
    @report_title = "Note Updates"
    @change_params = lambda { |user_id| { :controller => "note", :action => "history", :user_id => user_id } }
    render :action => "common"
  end

  def wiki_updates
    @users = Report.wiki_updates(@start_date, @end_date, @limit, @level)
    @report_title = "Wiki Updates"
    @change_params = lambda { |user_id| { :controller => "wiki", :action => "recent_changes", :user_id => user_id } }
    render :action => "common"
  end

  def post_uploads
    @users = Report.post_uploads(@start_date, @end_date, @limit, @level)
    @report_title = "Post Uploads"
    @change_params = lambda { |user_id| { :controller => "post", :action => "index", :tags => "user:#{User.find_name(user_id)}" } }
    render :action => "common"
  end

  def votes
    @users = Report.usage_by_user("post_votes", @start_date, @end_date, 29, 0, ["score > 0"], [], "updated_at")

    @users.each do |user|
      conds = ["updated_at BETWEEN ? AND ?"]
      params = []
      params << @start_date
      params << @end_date

      if user["user"]
        conds << "user_id = ?"
        params << user["id"]
      else
        # "Other":
        conds << "user_id NOT IN (?)"
        params << @users.select { |x| x["id"] }.map { |x| x["id"] }
      end

      votes = ActiveRecord::Base.connection.select_all(ActiveRecord::Base.sanitize_sql_array(["SELECT COUNT(score) AS sum, score FROM post_votes WHERE #{conds.join(" AND ")} GROUP BY score", *params]))
      user["votes"] = {}
      votes.each do |vote|
        score = vote["score"].to_i
        user["votes"][score] = vote["sum"]
      end
    end
  end

  private

  def set_dates
    @start_date = parse_date(params[:start_date]) || 3.days.ago.to_date
    @end_date = parse_date(params[:end_date]) || 1.day.from_now.to_date
    @level = parse_int(params[:level])
    @limit = (parse_int(params[:limit]) || 29).clamp(1, 100)
  end
end
