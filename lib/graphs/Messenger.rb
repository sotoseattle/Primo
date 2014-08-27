# Role of passer of messages for Loopy Belief Propagation.
module Messenger
   private
   attr_writer :incoming
   public
   attr_reader :incoming

   # Stores delta messages aligned with neighbors, so each delta's position is
   # the message passed from that neighbor to the node (self) along that edge
   def incoming
     @incoming ||= [nil]*neighbors.size
   end

  # Return message received from n
  def get_message_from(n)
    return incoming[neighbors.index(n)]
  end

  # Store message received from n
  def save_message_from(n, delta)
    self.incoming[neighbors.index(n)]= delta
  end
end
