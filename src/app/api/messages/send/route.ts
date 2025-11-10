import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://wnqifmvgvlmxgswhcwnc.supabase.co';
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InducWlmbXZndmxteGdzd2hjd25jIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTczMDgxMzI3MiwiZXhwIjoyMDQ2Mzg5MjcyfQ.UJa6LivB3H79x95cU8Y7Kt6YJqEpZNNCQ-Y7Hfcwxls';

const supabase = createClient(supabaseUrl, supabaseServiceKey);

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { receiverId, content, messageType = 'text', fileUrl } = body;
    
    // الحصول على معرف المرسل من الهيدر أو السيشن
    const authHeader = request.headers.get('authorization');
    const token = authHeader?.replace('Bearer ', '');
    
    // في الإنتاج، يجب التحقق من التوكن
    // هنا نستخدم معرف وهمي للتجربة
    const senderId = 'current_user_' + Date.now();
    
    // إنشاء الرسالة
    const { data: message, error } = await supabase
      .from('messages')
      .insert({
        sender_id: senderId,
        receiver_id: receiverId,
        content,
        message_type: messageType,
        file_url: fileUrl,
        is_read: false
      })
      .select()
      .single();
    
    if (error) {
      console.error('Error sending message:', error);
      return NextResponse.json({ error: error.message }, { status: 500 });
    }
    
    // تحديث أو إنشاء المحادثة
    const user1_id = senderId < receiverId ? senderId : receiverId;
    const user2_id = senderId < receiverId ? receiverId : senderId;
    
    await supabase
      .from('conversations')
      .upsert({
        user1_id,
        user2_id,
        last_message_id: message.id,
        last_message_time: message.created_at,
        updated_at: new Date().toISOString()
      }, {
        onConflict: 'user1_id,user2_id'
      });
    
    // إرسال إشعار للمستقبل
    await supabase
      .from('notifications')
      .insert({
        user_id: receiverId,
        title: 'رسالة جديدة',
        message: `لديك رسالة جديدة: ${content.substring(0, 50)}...`,
        type: 'info',
        link: `/messages?chat=${senderId}`,
        is_read: false
      });
    
    return NextResponse.json({
      success: true,
      data: message
    });
    
  } catch (error) {
    console.error('Server error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
