import 'framer-motion';

declare module 'framer-motion' {
  export interface HTMLMotionProps<T> {
    className?: string;
  }
}
