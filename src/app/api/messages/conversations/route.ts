import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://wnqifmvgvlmxgswhcwnc.supabase.co';
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InducWlmbXZndmxteGdzd2hjd25jIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTczMDgxMzI3MiwiZXhwIjoyMDQ2Mzg5MjcyfQ.UJa6LivB3H79x95cU8Y7Kt6YJqEpZNNCQ-Y7Hfcwxls';

const supabase = createClient(supabaseUrl, supabaseServiceKey);

export async function GET(request: NextRequest) {
  try {
    // الحصول على معرف المستخدم من الهيدر
    const authHeader = request.headers.get('authorization');
    const userId = 'current_user_' + Date.now(); // معرف وهمي للتجربة
    
    // جلب المحادثات
    const { data: conversations, error } = await supabase
      .from('conversations')
      .select('*')
      .or(`user1_id.eq.${userId},user2_id.eq.${userId}`)
      .order('last_message_time', { ascending: false });
    
    if (error) {
      console.error('Error fetching conversations:', error);
      return NextResponse.json({ error: error.message }, { status: 500 });
    }
    
    // تحويل البيانات للشكل المطلوب
    const formattedConversations = await Promise.all(
      (conversations || []).map(async (conv) => {
        const otherUserId = conv.user1_id === userId ? conv.user2_id : conv.user1_id;
        
        // جلب بيانات المستخدم الآخر
        const { data: user } = await supabase
          .from('users')
          .select('id, name, email, phone, role')
          .eq('id', otherUserId)
          .single();
        
        // جلب آخر رسالة
        const { data: lastMessage } = await supabase
          .from('messages')
          .select('content, created_at, sender_id')
          .eq('id', conv.last_message_id)
          .single();
        
        return {
          _id: conv.id,
          user: {
            _id: otherUserId,
            name: user?.name || 'مستخدم',
            email: user?.email || '',
            role: user?.role || 'student'
          },
          lastMessage: lastMessage ? {
            content: lastMessage.content,
            createdAt: lastMessage.created_at,
            sender: lastMessage.sender_id
          } : {
            content: '',
            createdAt: conv.created_at,
            sender: ''
          },
          unreadCount: conv.user1_id === userId ? conv.user1_unread_count : conv.user2_unread_count
        };
      })
    );
    
    return NextResponse.json({
      success: true,
      data: formattedConversations
    });
    
  } catch (error) {
    console.error('Server error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
