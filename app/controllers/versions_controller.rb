class VersionsController < ApplicationController
  before_filter :conflict?
  # test if someone else has edited the same item to undo
  def conflict?
    @version = Version.find_by_id(params[:id])
    @versions = Version.find(:all,:conditions => ["whodunnit = ? AND created_at = ?", @version.whodunnit,@version.created_at])
    @versions.each do |v|
      if v.item
        if v.item.versions.last.whodunnit.to_i != session[:user].id
          flash[:note] = "User #{User.find(v.item.versions.last.whodunnit).name} already edited this item."
          redirect_to :back
        end
      end
    end
  end

  def revert
    @versions.uniq.each do |v|
      if v.reify
        v.reify.save!
      else
        v.item.destroy
      end
    end
    redirect_to :back
  end
end